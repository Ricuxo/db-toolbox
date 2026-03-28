# DB Discovery — Queries de Arquitetura

> **Oracle Database · Uso Interno**  
> Este documento reúne todas as queries SQL utilizadas no script de discovery de arquitetura de banco de dados Oracle.  
> Execute com usuário que possua privilégio **DBA** ou **SELECT ANY DICTIONARY** para acesso completo.

---

## Índice

- [01. Banco de Dados & Instância](#01-banco-de-dados--instância)
- [02. Cards de Resumo — Contagens Gerais](#02-cards-de-resumo--contagens-gerais)
- [03. Sessões Ativas](#03-sessões-ativas)
- [04. Histórico de Conexões — AWR 30 dias](#04-histórico-de-conexões--awr-30-dias)
- [05. Usuários & Roles](#05-usuários--roles)
- [06. Objetos por Schema](#06-objetos-por-schema)
- [07. Tamanho por Schema](#07-tamanho-por-schema)
- [08. Tablespaces — Uso de Espaço](#08-tablespaces--uso-de-espaço)
- [09. Database Links](#09-database-links)
- [10. Jobs Agendados — DBMS_SCHEDULER](#10-jobs-agendados--dbms_scheduler)
- [11. Auditoria — Últimos 30 dias](#11-auditoria--últimos-30-dias)

---

## 01. Banco de Dados & Instância

**View / Objeto:** `V$DATABASE`, `V$INSTANCE`  
**Privilégio mínimo:** `SELECT ANY DICTIONARY`  
**Propósito:** Coleta baseline de identificação do ambiente — versão, plataforma, modo de log, data de criação e tempo de startup da instância.

```sql
SELECT
    d.name              AS "Database",
    d.db_unique_name    AS "Unique Name",
    d.platform_name     AS "Plataforma",
    d.log_mode          AS "Log Mode",
    d.open_mode         AS "Open Mode",
    TO_CHAR(d.created,
            'DD/MM/YYYY HH24:MI') AS "Criado em",
    i.instance_name     AS "Instancia",
    i.host_name         AS "Host",
    i.version           AS "Versao",
    i.status            AS "Status",
    TO_CHAR(i.startup_time,
            'DD/MM/YYYY HH24:MI') AS "Startup"
FROM v$database d, v$instance i;
```

---

## 02. Cards de Resumo — Contagens Gerais

**View / Objeto:** `DBA_USERS`, `DBA_OBJECTS`, `V$SESSION`, `DBA_DATA_FILES`, `DBA_SCHEDULER_JOBS`  
**Privilégio mínimo:** `DBA` ou `SELECT ANY DICTIONARY`  
**Propósito:** Visão executiva instantânea — totais de usuários, schemas, sessões ativas, tamanho do banco e jobs ativos.

```sql
-- Total de usuários não-Oracle
SELECT COUNT(*) AS "Usuarios"
FROM dba_users
WHERE oracle_maintained = 'N';

-- Total de schemas com objetos
SELECT COUNT(DISTINCT owner) AS "Schemas"
FROM dba_objects
WHERE owner NOT IN (
    SELECT username FROM dba_users
    WHERE oracle_maintained = 'Y'
);

-- Sessões ativas agora
SELECT COUNT(*) AS "Sessoes Ativas"
FROM v$session
WHERE username IS NOT NULL
  AND type = 'USER';

-- Tamanho total do banco (datafiles)
SELECT ROUND(SUM(bytes)/1024/1024/1024, 1) || ' GB' AS "Tamanho"
FROM dba_data_files;

-- Jobs ativos agendados
SELECT COUNT(*) AS "Jobs Ativos"
FROM dba_scheduler_jobs
WHERE owner NOT IN (
    SELECT username FROM dba_users
    WHERE oracle_maintained = 'Y'
)
AND enabled = 'TRUE';
```

---

## 03. Sessões Ativas

**View / Objeto:** `V$SESSION`  
**Privilégio mínimo:** `SELECT ON V$SESSION`  
**Propósito:** Identificar aplicações conectadas agora — usuário DB, usuário OS, máquina, programa, módulo e action. Fundamental para mapear aplicações em tempo real.

```sql
SELECT
    s.username   AS "Usuario DB",
    s.osuser     AS "OS User",
    s.machine    AS "Maquina",
    s.program    AS "Programa",
    s.module     AS "Modulo",
    s.action     AS "Action",
    TO_CHAR(s.logon_time,
            'DD/MM/YYYY HH24:MI') AS "Login",
    s.status     AS "Status",
    s.sid || ',' || s.serial# AS "SID,Serial"
FROM v$session s
WHERE s.username IS NOT NULL
  AND s.type = 'USER'
ORDER BY s.logon_time DESC;
```

---

## 04. Histórico de Conexões — AWR 30 dias

**View / Objeto:** `DBA_HIST_ACTIVE_SESS_HISTORY`, `DBA_USERS`  
**Privilégio mínimo:** `SELECT ON DBA_HIST_ACTIVE_SESS_HISTORY`  
**Propósito:** Descobrir aplicações offline, jobs batch e ETLs. Consulta o repositório AWR para identificar qualquer aplicação que se conectou nos últimos 30 dias, mesmo que não esteja ativa no momento da coleta.

> ⚠️ Requer licença **Oracle Diagnostics Pack** para acesso ao AWR.

```sql
SELECT
    u.username    AS "Usuario",
    s.machine     AS "Maquina",
    s.program     AS "Programa",
    s.module      AS "Modulo",
    COUNT(*)      AS "Total Samples",
    TO_CHAR(MIN(s.sample_time),
            'DD/MM/YY HH24:MI') AS "Primeira Vez",
    TO_CHAR(MAX(s.sample_time),
            'DD/MM/YY HH24:MI') AS "Ultima Vez"
FROM dba_hist_active_sess_history s
JOIN dba_users u ON u.user_id = s.user_id
WHERE s.sample_time >= SYSDATE - 30
  AND s.user_id > 0
GROUP BY u.username, s.machine,
         s.program, s.module
ORDER BY 5 DESC
FETCH FIRST 100 ROWS ONLY;
```

---

## 05. Usuários & Roles

**View / Objeto:** `DBA_USERS`, `DBA_ROLE_PRIVS`  
**Privilégio mínimo:** `SELECT ON DBA_USERS`, `SELECT ON DBA_ROLE_PRIVS`  
**Propósito:** Mapeamento de acessos e conformidade — lista todos os usuários não-Oracle com status da conta, data de criação, último login, profile e roles concedidas. Permite identificar usuários inativos.

```sql
SELECT
    u.username        AS "Usuario",
    u.account_status  AS "Status",
    TO_CHAR(u.created,
            'DD/MM/YYYY') AS "Criado",
    TO_CHAR(u.last_login,
            'DD/MM/YYYY HH24:MI') AS "Ultimo Login",
    u.profile         AS "Profile",
    LISTAGG(rp.granted_role, ', ')
        WITHIN GROUP (ORDER BY rp.granted_role) AS "Roles"
FROM dba_users u
LEFT JOIN dba_role_privs rp
    ON rp.grantee = u.username
WHERE u.oracle_maintained = 'N'
GROUP BY u.username, u.account_status,
         u.created, u.last_login, u.profile
ORDER BY u.last_login DESC NULLS LAST;
```

---

## 06. Objetos por Schema

**View / Objeto:** `DBA_OBJECTS`  
**Privilégio mínimo:** `SELECT ON DBA_OBJECTS`  
**Propósito:** Inventário e escopo de cada schema — lista todos os objetos agrupados por tipo (TABLE, VIEW, PROCEDURE, TRIGGER, INDEX, etc). Permite entender o tamanho e complexidade de cada aplicação.

```sql
SELECT
    owner       AS "Schema",
    object_type AS "Tipo",
    COUNT(*)    AS "Quantidade"
FROM dba_objects
WHERE owner NOT IN (
    SELECT username FROM dba_users
    WHERE oracle_maintained = 'Y'
)
GROUP BY owner, object_type
ORDER BY owner, object_type;
```

---

## 07. Tamanho por Schema

**View / Objeto:** `DBA_SEGMENTS`  
**Privilégio mínimo:** `SELECT ON DBA_SEGMENTS`  
**Propósito:** Dimensionamento e impacto de cada schema — consumo de espaço em disco em GB e MB, com contagem de segmentos. Útil para priorizar documentação e planejar crescimento.

```sql
SELECT
    s.owner AS "Schema",
    ROUND(SUM(s.bytes)/1024/1024/1024, 3) AS "Tamanho GB",
    COUNT(DISTINCT s.segment_name)         AS "Segmentos",
    ROUND(SUM(s.bytes)/1024/1024, 1)       AS "Tamanho MB"
FROM dba_segments s
WHERE s.owner NOT IN (
    SELECT username FROM dba_users
    WHERE oracle_maintained = 'Y'
)
GROUP BY s.owner
ORDER BY 2 DESC;
```

---

## 08. Tablespaces — Uso de Espaço

**View / Objeto:** `DBA_DATA_FILES`, `DBA_FREE_SPACE`  
**Privilégio mínimo:** `SELECT ON DBA_DATA_FILES`, `SELECT ON DBA_FREE_SPACE`  
**Propósito:** Monitoramento de capacidade e crescimento — capacidade total, espaço usado, espaço livre e percentual de uso de cada tablespace.

```sql
SELECT
    df.tablespace_name                              AS "Tablespace",
    ROUND(df.total_mb, 1)                           AS "Total MB",
    ROUND(df.total_mb - NVL(fs.free_mb, 0), 1)     AS "Usado MB",
    ROUND(NVL(fs.free_mb, 0), 1)                    AS "Livre MB",
    ROUND((df.total_mb - NVL(fs.free_mb, 0))
          / df.total_mb * 100, 1)                   AS "Uso %"
FROM
    (SELECT tablespace_name,
            SUM(bytes)/1024/1024 AS total_mb
     FROM dba_data_files
     GROUP BY tablespace_name) df
LEFT JOIN
    (SELECT tablespace_name,
            SUM(bytes)/1024/1024 AS free_mb
     FROM dba_free_space
     GROUP BY tablespace_name) fs
  ON df.tablespace_name = fs.tablespace_name
ORDER BY 5 DESC NULLS LAST;
```

---

## 09. Database Links

**View / Objeto:** `DBA_DB_LINKS`  
**Privilégio mínimo:** `SELECT ON DBA_DB_LINKS`  
**Propósito:** Mapeamento de integrações entre bancos — lista todos os DB Links existentes com owner, host de destino e usuário remoto. Revela dependências externas do banco.

```sql
SELECT
    owner    AS "Owner",
    db_link  AS "DB Link",
    username AS "Usuario Remoto",
    host     AS "Host",
    TO_CHAR(created, 'DD/MM/YYYY') AS "Criado"
FROM dba_db_links
ORDER BY owner;
```

---

## 10. Jobs Agendados — DBMS_SCHEDULER

**View / Objeto:** `DBA_SCHEDULER_JOBS`  
**Privilégio mínimo:** `SELECT ON DBA_SCHEDULER_JOBS`  
**Propósito:** Identificar processos automáticos e janelas de manutenção — lista todos os jobs agendados fora do escopo Oracle com tipo, intervalo, último início, próxima execução e estado.

```sql
SELECT
    owner         AS "Owner",
    job_name      AS "Job",
    job_type      AS "Tipo",
    schedule_type AS "Agenda",
    TO_CHAR(last_start_date,
            'DD/MM/YY HH24:MI') AS "Ultimo Inicio",
    TO_CHAR(next_run_date,
            'DD/MM/YY HH24:MI') AS "Proximo",
    state         AS "Estado",
    enabled       AS "Ativo"
FROM dba_scheduler_jobs
WHERE owner NOT IN (
    SELECT username FROM dba_users
    WHERE oracle_maintained = 'Y'
)
ORDER BY owner, job_name;
```

---

## 11. Auditoria — Últimos 30 dias

**View / Objeto:** `DBA_AUDIT_TRAIL`  
**Privilégio mínimo:** `SELECT ON DBA_AUDIT_TRAIL`  
**Propósito:** Rastreamento de acessos e ações no banco — agrupa registros de auditoria por usuário DB, usuário OS, host e ação. Útil para identificar aplicações por comportamento mesmo sem módulo/programa preenchido.

> ⚠️ Requer que a auditoria esteja habilitada (`AUDIT_TRAIL != NONE`).  
> A coluna correta é `OS_USERNAME` (não `OS_USER`) e `TIMESTAMP` (não `TIMESTAMP#`).

```sql
SELECT
    username     AS "Usuario DB",
    os_username  AS "OS User",
    userhost     AS "Host",
    action_name  AS "Acao",
    COUNT(*)     AS "Ocorrencias",
    TO_CHAR(MAX(timestamp),
            'DD/MM/YY HH24:MI') AS "Ultimo Acesso"
FROM dba_audit_trail
WHERE timestamp >= SYSDATE - 30
GROUP BY username, os_username,
         userhost, action_name
ORDER BY 5 DESC
FETCH FIRST 100 ROWS ONLY;
```

---

> ⚠️ **Documento confidencial — uso interno restrito à equipe DBA**
