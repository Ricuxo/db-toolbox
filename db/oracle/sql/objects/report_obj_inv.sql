---Resumo (rodar no CDB$ROOT)
SET LINES 200 PAGES 1000
COL pdb    FOR A15
COL schema FOR A25
COL tipo   FOR A20

SELECT c.name                                         AS pdb,
       o.owner                                        AS schema,
       o.object_type                                  AS tipo,
       COUNT(*)                                       AS quantidade,
       TO_CHAR(MAX(o.last_ddl_time),'DD/MM/YYYY HH24:MI') AS ult_ddl
FROM   cdb_objects  o
JOIN   v$containers c ON c.con_id = o.con_id
JOIN   cdb_users    u ON u.con_id = o.con_id
                     AND u.username = o.owner
                     AND u.oracle_maintained = 'N'
WHERE  o.status = 'INVALID'
GROUP  BY c.name, o.owner, o.object_type
ORDER  BY c.name, o.owner, quantidade DESC;


---Detalhes com o primeiro erro de compilação

COL objeto        FOR A40
COL primeiro_erro FOR A150

WITH err AS (
  SELECT e.con_id, e.owner, e.name, e.type,
         REPLACE(REPLACE(e.text, CHR(10), ' '), CHR(13), ' ') AS texto,
         ROW_NUMBER() OVER (PARTITION BY e.con_id, e.owner, e.name, e.type
                            ORDER BY e.sequence) AS rn
  FROM   cdb_errors e
  WHERE  e.attribute = 'ERROR'          -- ignora warnings PLW-
)
SELECT c.name                                       AS pdb,
       o.owner                                      AS schema,
       o.object_type                                AS tipo,
       o.object_name                                AS objeto,
       TO_CHAR(o.created,'DD/MM/YYYY')              AS criado_em,
       TO_CHAR(o.last_ddl_time,'DD/MM/YYYY HH24:MI') AS ultimo_ddl,
       NVL(err.texto,'(sem registro em DBA_ERRORS)') AS primeiro_erro
FROM   cdb_objects  o
JOIN   v$containers c ON c.con_id = o.con_id
JOIN   cdb_users    u ON u.con_id = o.con_id
                     AND u.username = o.owner
                     AND u.oracle_maintained = 'N'
LEFT   JOIN err      ON err.con_id = o.con_id
                     AND err.owner  = o.owner
                     AND err.name   = o.object_name
                     AND err.type   = o.object_type
                     AND err.rn     = 1
WHERE  o.status = 'INVALID'
ORDER  BY c.name, o.owner, o.object_type, o.object_name;