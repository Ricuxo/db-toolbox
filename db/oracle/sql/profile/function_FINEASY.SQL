----------------------------------------------------
---- CRIAÇÃO DA FUNÇÃO DE VERIFICAÇÃO DE SENHA -----
----------------------------------------------------

CREATE OR REPLACE FUNCTION FINEASY_VERIFY_FUNCTION(
    username     IN VARCHAR2,
    password     IN VARCHAR2,
    old_password IN VARCHAR2
) RETURN BOOLEAN AS

    -- Constantes de política
    v_min_length    CONSTANT PLS_INTEGER := 16;
    v_min_differ    CONSTANT PLS_INTEGER := 4;

    -- Contadores
    v_upper_count   PLS_INTEGER := 0;
    v_lower_count   PLS_INTEGER := 0;
    v_digit_count   PLS_INTEGER := 0;
    v_special_count PLS_INTEGER := 0;

    -- Caracteres permitidos como especiais
    v_special_chars CONSTANT VARCHAR2(64) := '!"#$%&()*+,-./:;<=>?@[\]^_`{|}~$';

    -- Variável de trabalho
    c               VARCHAR2(1);
    v_differ        PLS_INTEGER := 0;
    v_min_len       PLS_INTEGER;

BEGIN

    ------------------------------------------------------------
    -- 1. TAMANHO MÍNIMO
    ------------------------------------------------------------
    IF LENGTH(password) < v_min_length THEN
        raise_application_error(-20001,
            'Senha deve ter no mínimo ' || v_min_length || ' caracteres.');
    END IF;

    ------------------------------------------------------------
    -- 2. SENHA NÃO PODE CONTER OU SER IGUAL AO USERNAME
    ------------------------------------------------------------
    IF INSTR(UPPER(password), UPPER(username)) > 0 THEN
        raise_application_error(-20002,
            'Senha não pode conter o nome do usuário.');
    END IF;

    ------------------------------------------------------------
    -- 3. VARREDURA ÚNICA — classifica cada caractere
    ------------------------------------------------------------
    FOR i IN 1 .. LENGTH(password) LOOP
        c := SUBSTR(password, i, 1);

        IF c >= 'A' AND c <= 'Z' THEN
            v_upper_count := v_upper_count + 1;
        ELSIF c >= 'a' AND c <= 'z' THEN
            v_lower_count := v_lower_count + 1;
        ELSIF c >= '0' AND c <= '9' THEN
            v_digit_count := v_digit_count + 1;
        ELSIF INSTR(v_special_chars, c) > 0 THEN
            v_special_count := v_special_count + 1;
        END IF;
    END LOOP;

    ------------------------------------------------------------
    -- 4. VALIDAÇÕES DE COMPLEXIDADE
    ------------------------------------------------------------
    IF v_upper_count < 1 THEN
        raise_application_error(-20003,
            'Senha deve conter ao menos 1 letra maiúscula.');
    END IF;

    IF v_lower_count < 1 THEN
        raise_application_error(-20004,
            'Senha deve conter ao menos 1 letra minúscula.');
    END IF;

    IF v_digit_count < 1 THEN
        raise_application_error(-20005,
            'Senha deve conter ao menos 1 número.');
    END IF;

    IF v_special_count < 1 THEN
        raise_application_error(-20006,
            'Senha deve conter ao menos 1 caractere especial (!"#$%&()*+,...). ');
    END IF;

    ------------------------------------------------------------
    -- 5. DIFERENÇA EM RELAÇÃO À SENHA ANTERIOR
    --    Sempre executa, independente do tamanho
    ------------------------------------------------------------
    IF old_password IS NOT NULL THEN

        -- Senha nova não pode ser idêntica à anterior
        IF password = old_password THEN
            raise_application_error(-20007,
                'Nova senha não pode ser igual à senha anterior.');
        END IF;

        -- Conta diferenças posicionais + diferença de tamanho
        v_min_len := LEAST(LENGTH(password), LENGTH(old_password));
        v_differ  := ABS(LENGTH(password) - LENGTH(old_password));

        FOR i IN 1 .. v_min_len LOOP
            IF SUBSTR(password, i, 1) != SUBSTR(old_password, i, 1) THEN
                v_differ := v_differ + 1;
            END IF;
        END LOOP;

        IF v_differ < v_min_differ THEN
            raise_application_error(-20008,
                'Nova senha deve diferir da anterior em ao menos ' ||
                v_min_differ || ' caracteres.');
        END IF;

    END IF;

    ------------------------------------------------------------
    -- 6. APROVADA
    ------------------------------------------------------------
    RETURN TRUE;

END FINEASY_VERIFY_FUNCTION;
/


------------------------------------------------
---- CRIAÇÃO DO PROFILE DE USUÁRIO NOMINAL -----
------------------------------------------------

CREATE PROFILE "PROF_USR_NOMINAL_HML" LIMIT
    PASSWORD_VERIFY_FUNCTION    FINEASY_VERIFY_FUNCTION
    PASSWORD_LIFE_TIME          UNLIMITED
    PASSWORD_GRACE_TIME         10
    PASSWORD_LOCK_TIME          1/24
    PASSWORD_REUSE_MAX          6
    PASSWORD_REUSE_TIME         180
    FAILED_LOGIN_ATTEMPTS       10      -- mais tolerante que produção
    INACTIVE_ACCOUNT_TIME       180     -- ambientes parados por períodos longos
    SESSIONS_PER_USER           UNLIMITED
    IDLE_TIME                   60
    CONNECT_TIME                UNLIMITED;

-- Recria já com todos os parâmetros corretos de uma vez
CREATE PROFILE "PROF_USR_NOMINAL" LIMIT
    -- Complexidade de senha
    PASSWORD_VERIFY_FUNCTION    FINEASY_VERIFY_FUNCTION
    -- Ciclo de vida da senha
    PASSWORD_LIFE_TIME          90          -- expira a cada 90 dias (PCI-DSS)
    PASSWORD_GRACE_TIME         5           -- 5 dias para trocar após aviso
    PASSWORD_LOCK_TIME          1/24        -- bloqueia por 1 hora após tentativas falhas
    -- Reaproveitamento
    PASSWORD_REUSE_MAX          12          -- bloqueia as últimas 12 senhas
    PASSWORD_REUSE_TIME         365         -- e nos últimos 365 dias
    -- Tentativas de login
    FAILED_LOGIN_ATTEMPTS       5           -- bloqueia após 5 falhas consecutivas
    -- Contas inativas
    INACTIVE_ACCOUNT_TIME       90          -- bloqueia conta sem login há 90 dias
    -- Limites de sessão
    SESSIONS_PER_USER           5           -- máximo 5 sessões simultâneas
    IDLE_TIME                   30          -- encerra sessão ociosa após 30 min
    CONNECT_TIME                480         -- sessão máxima de 8 horas
    -- Recursos (UNLIMITED é aceitável para usuário nominal sem restrição de CPU/IO)
    COMPOSITE_LIMIT             UNLIMITED
    CPU_PER_SESSION             UNLIMITED
    CPU_PER_CALL                UNLIMITED
    LOGICAL_READS_PER_SESSION   UNLIMITED
    LOGICAL_READS_PER_CALL      UNLIMITED
    PRIVATE_SGA                 UNLIMITED;


--------------------------------------------------
---- CRIAÇÃO DO PROFILE DE USUÁRIO APLICAÇÃO -----
--------------------------------------------------

CREATE PROFILE "PROF_USR_APP" LIMIT
    -- SENHA: não expira automaticamente
    -- Troca é controlada por processo de change management (HORACIUS, ITSM)
    -- Expiração automática causa indisponibilidade de aplicação
    PASSWORD_LIFE_TIME          UNLIMITED
    -- Sem grace period pois senha não expira
    PASSWORD_GRACE_TIME         0
    -- Reaproveitamento: ainda controlamos histórico para quando houver troca manual
    PASSWORD_REUSE_MAX          12
    PASSWORD_REUSE_TIME         365
    -- Tentativas falhas: valor alto pois retry automático do pool
    -- pode disparar bloqueio em falha pontual de rede/restart
    FAILED_LOGIN_ATTEMPTS       10
    -- Bloqueio temporário (não permanente) — desbloqueio automático em 1h
    PASSWORD_LOCK_TIME          1/24
    -- Conta inativa: aplicação conecta continuamente — não bloquear
    INACTIVE_ACCOUNT_TIME       UNLIMITED
    -- Complexidade: função própria para aplicação
    -- Senhas de aplicação geralmente são geradas (ex: vault, secrets manager)
    -- e não precisam das mesmas regras de memorização humana
    PASSWORD_VERIFY_FUNCTION    FINEASY_VERIFY_FUNCTION
    -- Sessões: deve comportar o tamanho do connection pool
    -- Ajuste conforme o pool máximo configurado na aplicação
    -- UNLIMITED é aceitável se monitorado via Unified Audit / Enterprise Manager
    SESSIONS_PER_USER           UNLIMITED
    -- Idle time: NUNCA encerrar sessões de pool — conexões ociosas são normais
    IDLE_TIME                   UNLIMITED
    -- Connect time: sem limite — conexões de pool ficam abertas por horas/dias
    CONNECT_TIME                UNLIMITED
    COMPOSITE_LIMIT             UNLIMITED
    CPU_PER_SESSION             UNLIMITED
    CPU_PER_CALL                UNLIMITED
    LOGICAL_READS_PER_SESSION   UNLIMITED
    LOGICAL_READS_PER_CALL      UNLIMITED
    PRIVATE_SGA                 UNLIMITED;