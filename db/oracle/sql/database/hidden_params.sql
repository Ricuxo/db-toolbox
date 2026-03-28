Set lines 2000 
col NAME for a45 
col DESCRIPTION for a100 
SELECT name,description from SYS.V$PARAMETER WHERE name LIKE '\_%' ESCAPE '\';