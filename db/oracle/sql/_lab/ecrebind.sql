--
--
--  NAME
--    ecrebind.sql
--
--  DESCRIPTION
--    Mostra os indices que necessitam de rebuild!
--
--  HISTORY
--    02/06/2008 => Eduardo Chinelatto
--
-----------------------------------------------------------------------------
set wrap off
set lines 130
set pages 100



COL REBUILD FOR A8

SELECT OWNER, INDEX_NAME, BLEVEL, DECODE(SIGN(BLEVEL - 4), -1, 'NO', 'YES') REBUILD
FROM DBA_INDEXES
WHERE BLEVEL > 2;

--
-- Fim
--
