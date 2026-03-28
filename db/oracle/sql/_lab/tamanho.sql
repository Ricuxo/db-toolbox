SELECT 'Tipo: ' || SEGMENT_TYPE || ' - Obj:' || owner || '.' || segment_name || ' - Tablespace:' || tablespace_name Descricao,SUM(BYTES) / (1024*1024) MB, count(*) Nro_Extents
FROM dba_extents
WHERE SEGMENT_NAME = upper('&OBJ')
GROUP BY 'Tipo: ' || SEGMENT_TYPE || ' - Obj:' || owner || '.' || segment_name || ' - Tablespace:' || tablespace_name ;
