-- =============================================================================
-- db_discovery.sql -- Database Architecture Discovery
-- Gera relatorio HTML completo usando apenas SQL*Plus
--
-- USO:
--   sqlplus sys/senha@//host:1521/SID AS SYSDBA @db_discovery.sql
--
-- O relatorio sera salvo em: db_report_<data>.html
-- =============================================================================

-- Configuracoes do SQL*Plus
SET FEEDBACK OFF
SET VERIFY OFF
SET ECHO OFF
SET HEADING ON
SET PAGESIZE 50000
SET LINESIZE 32767
SET LONG 4000
SET LONGCHUNKSIZE 4000
SET TRIMOUT ON
SET TRIMSPOOL ON
SET NEWPAGE NONE
WHENEVER SQLERROR CONTINUE

-- Define nome do arquivo de saida com timestamp
COLUMN fname NEW_VALUE REPORT_FILE NOPRINT
SELECT 'db_report_' || TO_CHAR(SYSDATE,'YYYYMMDD_HH24MISS') || '.html' AS fname
FROM dual;

-- Ativa MARKUP HTML para as queries (as tabelas herdarao o estilo)
SET MARKUP HTML ON ENTMAP OFF SPOOL ON PREFORMAT OFF

SPOOL &REPORT_FILE

-- =============================================================================
-- HEAD do HTML -- injetado via PROMPT antes das queries
-- =============================================================================
PROMPT <!DOCTYPE html>
PROMPT <html lang="pt-BR">
PROMPT <head>
PROMPT <meta charset="UTF-8">
PROMPT <meta name="viewport" content="width=device-width,initial-scale=1">
PROMPT <title>DB Discovery Report</title>
PROMPT <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Roboto+Mono:wght@400;500;700&display=swap" rel="stylesheet">
PROMPT <style>
PROMPT :root{--bg:#0d0f1a;--bg2:#131625;--bg3:#1a1e30;--border:#252a42;--accent:#00e5ff;--text:#e2e8f0;--text2:#94a3b8;--yellow:#fbbf24;}
PROMPT *{box-sizing:border-box;margin:0;padding:0;}
PROMPT body{background:var(--bg);color:var(--text);font-family:'Inter',sans-serif;font-size:14px;line-height:1.7;padding:0;}
PROMPT /* Remove o HTML que o MARKUP HTML injeta automaticamente */
PROMPT body > table:first-of-type{display:none;}
PROMPT /* Header */
PROMPT .rpt-header{background:linear-gradient(135deg,#0d0f1a,#1a1e30,#0d0f1a);border-bottom:1px solid var(--border);padding:36px 48px 28px;position:relative;overflow:hidden;}
PROMPT .rpt-header::before{content:'';position:absolute;top:-60px;right:-60px;width:300px;height:300px;background:radial-gradient(circle,rgba(0,229,255,.08),transparent 70%);pointer-events:none;}
PROMPT .rpt-badge{display:inline-block;background:rgba(0,229,255,.1);border:1px solid rgba(0,229,255,.3);color:var(--accent);font-size:10px;letter-spacing:.2em;text-transform:uppercase;padding:4px 12px;border-radius:2px;margin-bottom:14px;}
PROMPT .rpt-header h1{font-size:30px;font-weight:700;color:#fff;letter-spacing:-.02em;}
PROMPT .rpt-header h1 span{color:var(--accent);}
PROMPT .rpt-meta{display:flex;gap:28px;margin-top:18px;flex-wrap:wrap;}
PROMPT .meta-item{display:flex;flex-direction:column;gap:2px;}
PROMPT .meta-label{font-size:10px;text-transform:uppercase;letter-spacing:.15em;color:var(--text2);}
PROMPT .meta-value{font-size:13px;color:var(--accent);font-weight:700;}
PROMPT /* Layout */
PROMPT .rpt-body{padding:28px 36px;}
PROMPT /* Secoes */
PROMPT .section{margin-bottom:28px;background:var(--bg2);border:1px solid var(--border);border-radius:4px;overflow:hidden;scroll-margin-top:20px;}
PROMPT .section-header{display:flex;align-items:center;gap:10px;padding:14px 20px;background:var(--bg3);border-bottom:1px solid var(--border);cursor:pointer;user-select:none;}
PROMPT .section-icon{font-size:15px;}
PROMPT .section-title{font-size:14px;font-weight:600;color:#fff;flex:1;}
PROMPT .section-subtitle{font-size:11px;color:var(--text2);}
PROMPT .collapse-btn{background:none;border:1px solid var(--border);color:var(--text2);padding:2px 8px;font-size:11px;border-radius:2px;cursor:pointer;transition:all .15s;}
PROMPT .collapse-btn:hover{border-color:var(--accent);color:var(--accent);}
PROMPT .section-body{padding:0;overflow-x:auto;}
PROMPT .section-body.collapsed{display:none;}
PROMPT /* Tabelas geradas pelo MARKUP HTML */
PROMPT .section-body table{width:100%!important;border-collapse:collapse!important;font-family:'Roboto Mono',monospace!important;font-size:13px!important;background:var(--bg2)!important;}
PROMPT .section-body table th{background:rgba(0,229,255,.08)!important;color:var(--accent)!important;font-weight:700!important;text-align:left!important;padding:11px 16px!important;border-bottom:1px solid var(--border)!important;font-size:11px!important;text-transform:uppercase!important;white-space:nowrap;}
PROMPT .section-body table td{padding:9px 16px!important;border-bottom:1px solid rgba(255,255,255,.04)!important;color:var(--text)!important;vertical-align:top!important;max-width:400px;word-break:break-word;}
PROMPT .section-body table tr:hover td{background:rgba(255,255,255,.03)!important;}
PROMPT .section-body table tr:last-child td{border-bottom:none!important;}
PROMPT /* Badge contador de linhas e rodape de tabela */
PROMPT .row-badge{display:inline-block;background:rgba(0,229,255,.12);border:1px solid rgba(0,229,255,.25);color:var(--accent);font-size:10px;font-weight:700;padding:2px 9px;border-radius:10px;margin-left:8px;letter-spacing:.03em;white-space:nowrap;}
PROMPT .row-badge.zero{background:rgba(251,191,36,.1);border-color:rgba(251,191,36,.3);color:var(--yellow);}
PROMPT .table-footer td{background:rgba(0,229,255,.05)!important;color:var(--text2)!important;font-size:11px!important;font-style:italic;border-top:1px solid var(--border)!important;}
PROMPT /* Cards de resumo */
PROMPT .summary-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:14px;margin-bottom:28px;}
PROMPT .summary-card{background:var(--bg2);border:1px solid var(--border);border-radius:4px;padding:18px;position:relative;overflow:hidden;}
PROMPT .summary-card::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:var(--accent);}
PROMPT .summary-card.warn::before{background:var(--yellow);}
PROMPT .card-icon{font-size:20px;margin-bottom:6px;}
PROMPT .card-value{font-size:20px;font-weight:700;color:var(--accent);line-height:1;word-break:break-all;}
PROMPT .summary-card.warn .card-value{color:var(--yellow);}
PROMPT .card-label{font-size:11px;color:var(--text2);margin-top:3px;}
PROMPT /* Rodape */
PROMPT .rpt-footer{text-align:center;padding:18px;border-top:1px solid var(--border);color:var(--text2);font-size:11px;background:var(--bg2);margin-top:28px;}
PROMPT ::-webkit-scrollbar{width:5px;height:5px;}
PROMPT ::-webkit-scrollbar-track{background:var(--bg);}
PROMPT ::-webkit-scrollbar-thumb{background:var(--border);border-radius:3px;}
PROMPT </style>
PROMPT </head>
PROMPT <body>

-- =============================================================================
-- HEADER com dados dinamicos do banco
-- =============================================================================
SET MARKUP HTML OFF
PROMPT <div class="rpt-header">
PROMPT   <div class="rpt-badge">DB Discovery Report</div>
PROMPT   <h1>Database <span>Architecture</span> Discovery</h1>
PROMPT   <div class="rpt-meta">
SET MARKUP HTML ON

-- Injeta os metadados dinamicos como celulas visiveis
-- Truque: query sem tabela visivel, usamos PROMPT para estrutura e query para valor
SET MARKUP HTML OFF
PROMPT     <div class="meta-item"><span class="meta-label">Gerado em</span><span class="meta-value">
SET MARKUP HTML ON
SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS') AS " " FROM dual;
SET MARKUP HTML OFF
PROMPT     </span></div>
SET MARKUP HTML ON

SET MARKUP HTML OFF
PROMPT     <div class="meta-item"><span class="meta-label">Database</span><span class="meta-value">
SET MARKUP HTML ON
SELECT name AS " " FROM v$database;
SET MARKUP HTML OFF
PROMPT     </span></div>
SET MARKUP HTML ON

SET MARKUP HTML OFF
PROMPT     <div class="meta-item"><span class="meta-label">Versao</span><span class="meta-value">
SET MARKUP HTML ON
SELECT version AS " " FROM v$instance;
SET MARKUP HTML OFF
PROMPT     </span></div>
SET MARKUP HTML ON

SET MARKUP HTML OFF
PROMPT     <div class="meta-item"><span class="meta-label">Host</span><span class="meta-value">
SET MARKUP HTML ON
SELECT host_name AS " " FROM v$instance;
SET MARKUP HTML OFF
PROMPT     </span></div>
PROMPT   </div>
PROMPT </div>
PROMPT <div class="rpt-body">

-- =============================================================================
-- CARDS DE RESUMO (contagens gerais)
-- =============================================================================
PROMPT <div class="summary-grid">
SET MARKUP HTML ON

-- Card: total de usuarios
SET MARKUP HTML OFF
PROMPT <div class="summary-card"><div class="card-icon">&#128100;</div><div class="card-value">
SET MARKUP HTML ON
SELECT COUNT(*) AS " " FROM dba_users WHERE oracle_maintained = 'N';
SET MARKUP HTML OFF
PROMPT </div><div class="card-label">Usuarios</div></div>
SET MARKUP HTML ON

-- Card: total de schemas com objetos
SET MARKUP HTML OFF
PROMPT <div class="summary-card"><div class="card-icon">&#128230;</div><div class="card-value">
SET MARKUP HTML ON
SELECT COUNT(DISTINCT owner) AS " "
FROM dba_objects
WHERE owner NOT IN (SELECT username FROM dba_users WHERE oracle_maintained='Y');
SET MARKUP HTML OFF
PROMPT </div><div class="card-label">Schemas</div></div>
SET MARKUP HTML ON

-- Card: sessoes ativas
SET MARKUP HTML OFF
PROMPT <div class="summary-card"><div class="card-icon">&#9889;</div><div class="card-value">
SET MARKUP HTML ON
SELECT COUNT(*) AS " " FROM v$session WHERE username IS NOT NULL AND type='USER';
SET MARKUP HTML OFF
PROMPT </div><div class="card-label">Sessoes Ativas</div></div>
SET MARKUP HTML ON

-- Card: tamanho total do banco
SET MARKUP HTML OFF
PROMPT <div class="summary-card"><div class="card-icon">&#128190;</div><div class="card-value">
SET MARKUP HTML ON
SELECT ROUND(SUM(bytes)/1024/1024/1024,1) || ' GB' AS " " FROM dba_data_files;
SET MARKUP HTML OFF
PROMPT </div><div class="card-label">Tamanho Total</div></div>
SET MARKUP HTML ON

-- Card: jobs ativos
SET MARKUP HTML OFF
PROMPT <div class="summary-card"><div class="card-icon">&#9200;</div><div class="card-value">
SET MARKUP HTML ON
SELECT COUNT(*) AS " " FROM dba_scheduler_jobs
WHERE owner NOT IN (SELECT username FROM dba_users WHERE oracle_maintained='Y')
AND enabled = 'TRUE';
SET MARKUP HTML OFF
PROMPT </div><div class="card-label">Jobs Ativos</div></div>
PROMPT </div>

-- =============================================================================
-- MACRO para gerar abertura de secao (simulado com PROMPT)
-- =============================================================================

-- =============================================================================
-- SECAO 1: Banco de Dados e Instancia
-- =============================================================================
PROMPT <div class="section">
PROMPT <div class="section-header" onclick="toggleSection(this)">
PROMPT <span class="section-icon">&#128374;</span>
PROMPT <div><div class="section-title">Banco de Dados &amp; Instancia</div>
PROMPT <div class="section-subtitle">Versao, modo, plataforma, startup time</div></div>
PROMPT <button class="collapse-btn">&#8722;</button></div>
PROMPT <div class="section-body">
SET MARKUP HTML ON

SELECT
    d.name              AS "Database",
    d.db_unique_name    AS "Unique Name",
    d.platform_name     AS "Plataforma",
    d.log_mode          AS "Log Mode",
    d.open_mode         AS "Open Mode",
    TO_CHAR(d.created,'DD/MM/YYYY HH24:MI') AS "Criado em",
    i.instance_name     AS "Instancia",
    i.host_name         AS "Host",
    i.version           AS "Versao",
    i.status            AS "Status",
    TO_CHAR(i.startup_time,'DD/MM/YYYY HH24:MI') AS "Startup"
FROM v$database d, v$instance i;

SET MARKUP HTML OFF
PROMPT </div></div>

-- =============================================================================
-- SECAO 2: Sessoes Ativas
-- =============================================================================
PROMPT <div class="section">
PROMPT <div class="section-header" onclick="toggleSection(this)">
PROMPT <span class="section-icon">&#9889;</span>
PROMPT <div><div class="section-title">Sessoes Ativas</div>
PROMPT <div class="section-subtitle">Quem esta conectado agora - usuario, maquina, programa, modulo</div></div>
PROMPT <button class="collapse-btn">&#8722;</button></div>
PROMPT <div class="section-body">
SET MARKUP HTML ON

SELECT
    s.username   AS "Usuario DB",
    s.osuser     AS "OS User",
    s.machine    AS "Maquina",
    s.program    AS "Programa",
    s.module     AS "Modulo",
    s.action     AS "Action",
    TO_CHAR(s.logon_time,'DD/MM/YYYY HH24:MI') AS "Login",
    s.status     AS "Status",
    s.sid || ',' || s.serial# AS "SID,Serial"
FROM v$session s
WHERE s.username IS NOT NULL
  AND s.type = 'USER'
ORDER BY s.logon_time DESC;

SET MARKUP HTML OFF
PROMPT </div></div>

-- =============================================================================
-- SECAO 3: Historico de Conexoes (AWR - ultimos 30 dias)
-- =============================================================================
PROMPT <div class="section">
PROMPT <div class="section-header" onclick="toggleSection(this)">
PROMPT <span class="section-icon">&#128197;</span>
PROMPT <div><div class="section-title">Historico de Conexoes (AWR)</div>
PROMPT <div class="section-subtitle">Ultimos 30 dias - identifica aplicacoes mesmo offline</div></div>
PROMPT <button class="collapse-btn">&#8722;</button></div>
PROMPT <div class="section-body">
SET MARKUP HTML ON

SELECT
    u.username    AS "Usuario",
    s.machine     AS "Maquina",
    s.program     AS "Programa",
    s.module      AS "Modulo",
    COUNT(*)      AS "Total Samples",
    TO_CHAR(MIN(s.sample_time),'DD/MM/YY HH24:MI') AS "Primeira Vez",
    TO_CHAR(MAX(s.sample_time),'DD/MM/YY HH24:MI') AS "Ultima Vez"
FROM dba_hist_active_sess_history s
JOIN dba_users u ON u.user_id = s.user_id
WHERE s.sample_time >= SYSDATE - 30
  AND s.user_id > 0
GROUP BY u.username, s.machine, s.program, s.module
ORDER BY 5 DESC
FETCH FIRST 100 ROWS ONLY;

SET MARKUP HTML OFF
PROMPT </div></div>

-- =============================================================================
-- SECAO 4: Usuarios e Roles
-- =============================================================================
PROMPT <div class="section">
PROMPT <div class="section-header" onclick="toggleSection(this)">
PROMPT <span class="section-icon">&#128100;</span>
PROMPT <div><div class="section-title">Usuarios &amp; Roles</div>
PROMPT <div class="section-subtitle">Status, ultimo login, roles atribuidas</div></div>
PROMPT <button class="collapse-btn">&#8722;</button></div>
PROMPT <div class="section-body">
SET MARKUP HTML ON

SELECT
    u.username       AS "Usuario",
    u.account_status AS "Status",
    TO_CHAR(u.created,'DD/MM/YYYY') AS "Criado",
    TO_CHAR(u.last_login,'DD/MM/YYYY HH24:MI') AS "Ultimo Login",
    u.profile        AS "Profile",
    LISTAGG(rp.granted_role, ', ')
        WITHIN GROUP (ORDER BY rp.granted_role) AS "Roles"
FROM dba_users u
LEFT JOIN dba_role_privs rp ON rp.grantee = u.username
WHERE u.oracle_maintained = 'N'
GROUP BY u.username, u.account_status, u.created, u.last_login, u.profile
ORDER BY u.last_login DESC NULLS LAST;

SET MARKUP HTML OFF
PROMPT </div></div>

-- =============================================================================
-- SECAO 5: Objetos por Schema
-- =============================================================================
PROMPT <div class="section">
PROMPT <div class="section-header" onclick="toggleSection(this)">
PROMPT <span class="section-icon">&#128230;</span>
PROMPT <div><div class="section-title">Objetos por Schema</div>
PROMPT <div class="section-subtitle">Inventario: tabelas, procedures, views, triggers...</div></div>
PROMPT <button class="collapse-btn">&#8722;</button></div>
PROMPT <div class="section-body">
SET MARKUP HTML ON

SELECT
    owner       AS "Schema",
    object_type AS "Tipo",
    COUNT(*)    AS "Quantidade"
FROM dba_objects
WHERE owner NOT IN (
    SELECT username FROM dba_users WHERE oracle_maintained = 'Y'
)
GROUP BY owner, object_type
ORDER BY owner, object_type;

SET MARKUP HTML OFF
PROMPT </div></div>

-- =============================================================================
-- SECAO 6: Tamanho por Schema
-- =============================================================================
PROMPT <div class="section">
PROMPT <div class="section-header" onclick="toggleSection(this)">
PROMPT <span class="section-icon">&#128190;</span>
PROMPT <div><div class="section-title">Tamanho por Schema</div>
PROMPT <div class="section-subtitle">Consumo de espaco em disco por schema</div></div>
PROMPT <button class="collapse-btn">&#8722;</button></div>
PROMPT <div class="section-body">
SET MARKUP HTML ON

SELECT
    s.owner AS "Schema",
    ROUND(SUM(s.bytes)/1024/1024/1024, 3) AS "Tamanho GB",
    COUNT(DISTINCT s.segment_name)         AS "Segmentos",
    ROUND(SUM(s.bytes)/1024/1024, 1)       AS "Tamanho MB"
FROM dba_segments s
WHERE s.owner NOT IN (
    SELECT username FROM dba_users WHERE oracle_maintained = 'Y'
)
GROUP BY s.owner
ORDER BY 2 DESC;

SET MARKUP HTML OFF
PROMPT </div></div>

-- =============================================================================
-- SECAO 7: Tablespaces
-- =============================================================================
PROMPT <div class="section">
PROMPT <div class="section-header" onclick="toggleSection(this)">
PROMPT <span class="section-icon">&#128202;</span>
PROMPT <div><div class="section-title">Tablespaces</div>
PROMPT <div class="section-subtitle">Capacidade, uso e espaco livre</div></div>
PROMPT <button class="collapse-btn">&#8722;</button></div>
PROMPT <div class="section-body">
SET MARKUP HTML ON

SELECT
    df.tablespace_name AS "Tablespace",
    ROUND(df.total_mb, 1) AS "Total MB",
    ROUND(df.total_mb - NVL(fs.free_mb, 0), 1) AS "Usado MB",
    ROUND(NVL(fs.free_mb, 0), 1) AS "Livre MB",
    ROUND((df.total_mb - NVL(fs.free_mb, 0)) / df.total_mb * 100, 1) AS "Uso %"
FROM
    (SELECT tablespace_name, SUM(bytes)/1024/1024 AS total_mb
     FROM dba_data_files GROUP BY tablespace_name) df
LEFT JOIN
    (SELECT tablespace_name, SUM(bytes)/1024/1024 AS free_mb
     FROM dba_free_space GROUP BY tablespace_name) fs
  ON df.tablespace_name = fs.tablespace_name
ORDER BY 5 DESC NULLS LAST;

SET MARKUP HTML OFF
PROMPT </div></div>

-- =============================================================================
-- SECAO 8: Database Links
-- =============================================================================
PROMPT <div class="section">
PROMPT <div class="section-header" onclick="toggleSection(this)">
PROMPT <span class="section-icon">&#128279;</span>
PROMPT <div><div class="section-title">Database Links</div>
PROMPT <div class="section-subtitle">Integracoes entre bancos de dados</div></div>
PROMPT <button class="collapse-btn">&#8722;</button></div>
PROMPT <div class="section-body">
SET MARKUP HTML ON

SELECT
    owner    AS "Owner",
    db_link  AS "DB Link",
    username AS "Usuario Remoto",
    host     AS "Host",
    TO_CHAR(created, 'DD/MM/YYYY') AS "Criado"
FROM dba_db_links
ORDER BY owner;

SET MARKUP HTML OFF
PROMPT </div></div>

-- =============================================================================
-- SECAO 9: Jobs Agendados
-- =============================================================================
PROMPT <div class="section">
PROMPT <div class="section-header" onclick="toggleSection(this)">
PROMPT <span class="section-icon">&#9200;</span>
PROMPT <div><div class="section-title">Jobs Agendados</div>
PROMPT <div class="section-subtitle">DBMS_SCHEDULER - processos automaticos</div></div>
PROMPT <button class="collapse-btn">&#8722;</button></div>
PROMPT <div class="section-body">
SET MARKUP HTML ON

SELECT
    owner           AS "Owner",
    job_name        AS "Job",
    job_type        AS "Tipo",
    schedule_type   AS "Agenda",
    TO_CHAR(last_start_date, 'DD/MM/YY HH24:MI') AS "Ultimo Inicio",
    TO_CHAR(next_run_date,   'DD/MM/YY HH24:MI') AS "Proximo",
    state           AS "Estado",
    enabled         AS "Ativo"
FROM dba_scheduler_jobs
WHERE owner NOT IN (
    SELECT username FROM dba_users WHERE oracle_maintained = 'Y'
)
ORDER BY owner, job_name;

SET MARKUP HTML OFF
PROMPT </div></div>

-- =============================================================================
-- SECAO 10: Auditoria (ultimos 30 dias)
-- =============================================================================
PROMPT <div class="section">
PROMPT <div class="section-header" onclick="toggleSection(this)">
PROMPT <span class="section-icon">&#128269;</span>
PROMPT <div><div class="section-title">Auditoria - Ultimos 30 dias</div>
PROMPT <div class="section-subtitle">Rastreamento de acoes via DBA_AUDIT_TRAIL</div></div>
PROMPT <button class="collapse-btn">&#8722;</button></div>
PROMPT <div class="section-body">
SET MARKUP HTML ON

SELECT
    username     AS "Usuario DB",
    os_username  AS "OS User",
    userhost     AS "Host",
    action_name  AS "Acao",
    COUNT(*)     AS "Ocorrencias",
    TO_CHAR(MAX(timestamp), 'DD/MM/YY HH24:MI') AS "Ultimo Acesso"
FROM dba_audit_trail
WHERE timestamp >= SYSDATE - 30
GROUP BY username, os_username, userhost, action_name
ORDER BY 5 DESC
FETCH FIRST 100 ROWS ONLY;

SET MARKUP HTML OFF
PROMPT </div></div>

-- =============================================================================
-- RODAPE + JAVASCRIPT
-- =============================================================================
PROMPT <div class="rpt-footer">
PROMPT   Gerado por <strong>db_discovery.sql</strong> &nbsp;|&nbsp;
PROMPT   &#9888; Documento confidencial - uso interno restrito a equipe DBA
PROMPT </div>
PROMPT </div><!-- /rpt-body -->

PROMPT <script>
PROMPT function toggleSection(header){
PROMPT   const body=header.nextElementSibling;
PROMPT   const btn=header.querySelector('.collapse-btn');
PROMPT   body.classList.toggle('collapsed');
PROMPT   btn.textContent=body.classList.contains('collapsed')?'+':'\u2212';
PROMPT }
PROMPT // Contagem de linhas: badge no titulo + rodape na tabela
PROMPT document.querySelectorAll('.section').forEach(section=>{
PROMPT   const table=section.querySelector('table');
PROMPT   const titleEl=section.querySelector('.section-title');
PROMPT   if(!table||!titleEl) return;
PROMPT   const rows=table.querySelectorAll('tbody tr');
PROMPT   const count=rows.length;
PROMPT   const badge=document.createElement('span');
PROMPT   badge.className='row-badge'+(count===0?' zero':'');
PROMPT   badge.textContent=count===0?'0 registros':count+' registro'+(count>1?'s':'');
PROMPT   titleEl.appendChild(badge);
PROMPT   if(count>0){
PROMPT     const cols=table.querySelector('tr').querySelectorAll('th,td').length;
PROMPT     const tfoot=document.createElement('tfoot');
PROMPT     tfoot.innerHTML='<tr class="table-footer"><td colspan="'+cols+'">&#8627; '+count+' registro'+(count>1?'s':'')+' exibido'+(count>1?'s':'')+'</td></tr>';
PROMPT     table.appendChild(tfoot);
PROMPT   }
PROMPT });
PROMPT </script>
PROMPT </body>
PROMPT </html>

-- Fecha o spool
SPOOL OFF

-- Confirmacao no terminal
SET MARKUP HTML OFF
SET FEEDBACK ON
PROMPT ============================================
PROMPT Relatorio gerado: &REPORT_FILE
PROMPT Abra no navegador: firefox &REPORT_FILE
PROMPT ============================================
EXIT;