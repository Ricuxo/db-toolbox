REM " Gera scripts de Reorg"
REM " Autor - Luiz Noronha - 26/10/2009"

SET verify 		OFF;
SET lin 		120;
SET FEED 		OFF;
col NAME_COL_PLUS_SHOW_PARAM 	for a40
col VALUE_COL_PLUS_SHOW_PARAM 	for a40
col segment_space_management 	for a5
col allocation_type		for a10

ALTER SESSION SET NLS_NUMERIC_CHARACTERS='.,';

COLUMN "<= 1024" HEADING 'QTDE OBJECTS|<= 1024 EXTENTS';
COLUMN "> 1024 AND < 3072" HEADING 'QTDE OBJECTS|> 1024 AND < 3072 EXTENTS';
COLUMN "> 3072" HEADING 'QTDE OBJECTS|> 3072 EXTENTS';
COLUMN extent_management HEADING 'EXTENT|MANAGEMENT';
COLUMN segment_space_management HEADING 'ASSM';
COLUMN allocation_type HEADING 'ALLOCATION|TYPE';
COLUMN next_extent HEADING 'UNIFORM|SIZE';

SELECT a.segment_type, NVL(SUM(a.M128),0) AS "<= 128MB",
       NVL(SUM(a.G4),0) AS "> 128M AND <= 4GB",
       NVL(SUM(a.G128),0) AS "> 4G AND <= 128GB",
       NVL(SUM(a.BIG),0) AS "> 128GB"
FROM(
SELECT segment_type,
       CASE WHEN (BYTES/1024/1024) <= 128 THEN 1 ELSE 0 END AS M128, 
       CASE WHEN (BYTES/1024/1024) > 128  AND (BYTES/1024/1024) <= 4096 THEN 1 ELSE 0 END AS G4,
       CASE WHEN (BYTES/1024/1024) > 4096 AND (BYTES/1024/1024) <= 131072 THEN 1 ELSE 0 END AS G128,
       CASE WHEN (BYTES/1024/1024) > 131072 THEN 1 ELSE 0 END AS BIG
FROM dba_segments
WHERE tablespace_name = '&1'
AND segment_name NOT LIKE ('BIN$%') ) A --Desconsiderando as tabelas da lixeira.)
GROUP BY a.segment_type
ORDER BY 1;

UNDEFINE 1

