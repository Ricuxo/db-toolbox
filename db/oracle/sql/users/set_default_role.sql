SET SERVEROUTPUT ON
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF TRIMSPOOL ON

-- Lista de usuários (adicione aqui os usuários desejados)
DEFINE usuarios = 'A1932031,A1931887,T010572,BRRZAL,BRJWB,A1931192,T003649,T004228,A1947702,ADMIT,ADMSLG,ADMCO'

-- Separador
PROMPT =====================================
PROMPT Gerando comandos de DEFAULT ROLE para os usuários
PROMPT =====================================

-- Loop por cada usuário da lista
BEGIN
    FOR user_rec IN (
        SELECT REGEXP_SUBSTR('&usuarios', '[^,]+', 1, LEVEL) AS username
        FROM dual
        CONNECT BY REGEXP_SUBSTR('&usuarios', '[^,]+', 1, LEVEL) IS NOT NULL
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('-- Usuário: ' || user_rec.username);

        -- Captura as roles atribuídas diretamente ao usuário
        FOR role_rec IN (
            SELECT granted_role
            FROM dba_role_privs
            WHERE grantee = UPPER(user_rec.username)
        )
        LOOP
            NULL; -- Apenas força o LOOP
        END LOOP;

        DECLARE
            v_roles VARCHAR2(4000);
        BEGIN
            SELECT LISTAGG(granted_role, ', ') WITHIN GROUP (ORDER BY granted_role)
              INTO v_roles
              FROM dba_role_privs
             WHERE grantee = UPPER(user_rec.username);

            IF v_roles IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('ALTER USER ' || user_rec.username || ' DEFAULT ROLE ' || v_roles || ';');
            ELSE
                DBMS_OUTPUT.PUT_LINE('-- Nenhuma role encontrada para o usuário ' || user_rec.username);
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('-- Nenhuma role atribuída para o usuário ' || user_rec.username);
        END;

        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
END;
/

SET FEEDBACK ON HEADING ON PAGESIZE 14
