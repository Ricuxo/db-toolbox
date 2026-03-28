--- Encontrar maior objeto do banco
--- Sub select filta os dados e faz a conta, e o principal limita a quantidade de linhas.

SELECT * FROM (select OWNER,SEGMENT_NAME,SEGMENT_TYPE,BYTES/1024/1024 from dba_segments 
where SEGMENT_NAME NOT LIKE 'BIN$%' order by BYTES DESC) WHERE ROWNUM <10 ;        