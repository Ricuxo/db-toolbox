REM " Gera scripts de Reorg"
REM " Autor - Luiz Noronha - 26/10/2009"

SET heading 	ON;
SET verify 		OFF;
SET lin 		220;
SET FEED 		OFF;
SET PAGES               500;
REPHEADER 		ON;
TTITLE 			ON;
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

TTITLE CENTER 'R E O R G - P R O G R A M - SAFE COMPLIANCE' 

SELECT owner, COUNT(1) TOTAL_OBJECTS FROM dba_OBJECTS
GROUP BY owner;

PROMPT 
PROMPT 

ACCEPT v_owner PROMPT "Digite o nome do owner desejado......................: "
TTITLE OFF;
PROMPT
PROMPT
PROMPT ====OWNER &&v_owner - Total de objetos por numero de Extents e tablespace====

SELECT a.tablespace_name, 
       extent_management, 
       DECODE(segment_space_management,'AUTO','ON','OFF') segment_space_management, 
       allocation_type, 
       next_extent,
       NVL(SUM(b.M1024),0) AS "<= 1024" , 
       NVL(SUM(b.E3072),0) AS "> 1024 AND <= 3072" , 
       NVL(SUM(b.M3072),0) AS "> 3072"
FROM dba_tablespaces a 
RIGHT JOIN (
SELECT tablespace_name,
       CASE WHEN extents <= 1024 THEN 1 ELSE 0 END AS M1024, 
       CASE WHEN extents > 1024  AND extents <= 3072 THEN 1 ELSE 0 END AS E3072,
       CASE WHEN extents > 3072 THEN 1 ELSE 0 END AS M3072
 FROM dba_segments
WHERE owner = '&&v_owner') b
   ON (a.tablespace_name = b.tablespace_name)
GROUP BY a.tablespace_name,extent_management,segment_space_management, allocation_type, next_extent
ORDER BY 1;

PROMPT
PROMPT

PROMPT ====Tamanho de Segmento x Tablespace ====

SELECT a.TABLESPACE_NAME, NVL(SUM(a.M128),0) AS "<= 128MB",
       NVL(SUM(a.G4),0) AS "> 128M AND <= 4GB",
       NVL(SUM(a.G128),0) AS "> 4G AND <= 128GB",
       NVL(SUM(a.BIG),0) AS "> 128GB"
FROM(
SELECT TABLESPACE_NAME,
       CASE WHEN (BYTES/1024/1024) <= 128 THEN 1 ELSE 0 END AS M128, 
       CASE WHEN (BYTES/1024/1024) > 128  AND (BYTES/1024/1024) <= 4096 THEN 1 ELSE 0 END AS G4,
       CASE WHEN (BYTES/1024/1024) > 4096 AND (BYTES/1024/1024) <= 131072 THEN 1 ELSE 0 END AS G128,
       CASE WHEN (BYTES/1024/1024) > 131072 THEN 1 ELSE 0 END AS BIG
FROM dba_segments
WHERE owner = '&&v_owner') a
GROUP BY a.TABLESPACE_NAME
ORDER BY 1;

PROMPT
PROMPT
PROMPT ====OWNER &&v_owner - Total de indices por tamanho de segmento e segment_type====

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
WHERE owner = '&&v_owner'
AND segment_name NOT LIKE ('BIN$%') ) A --Desconsiderando as tabelas da lixeira.)
GROUP BY a.segment_type
ORDER BY 1;

UNDEFINE v_owner

