--
-- Lista os datafiles da(s) tablespace(s) especificada(s)
--
-- Uso: @tbsdf <NOME_DA_TABLESPACE> -- Podem ser usados 'wildcards'
--                                   Ex.: @tbsdf %_DATA_%
--
@cab
--
column FILE_NAME format a105
--
break on TABLESPACE_NAME skip 1 nodup
column MB      format 999999999
column FILE_ID format 9999
select a.TABLESPACE_NAME, a.STATUS, a.BYTES / 1024 / 1024 MB, a.FILE_ID, b.CREATION_TIME, b.LAST_TIME, a.FILE_NAME
  from DBA_DATA_FILES a, V$DATAFILE b
 where a.TABLESPACE_NAME like upper( '&1' )
   and b.FILE# = a.FILE_ID
 order by a.TABLESPACE_NAME, creation_time;
--
column MB      format 99999
column FILE_ID format 9999
select a.TABLESPACE_NAME, a.STATUS, a.BYTES / 1024 / 1024 MB, a.FILE_ID, a.FILE_NAME
  from DBA_TEMP_FILES a, V$TEMPFILE b
 where a.TABLESPACE_NAME like upper( '&1' )
   and b.FILE# = a.FILE_ID
 order by a.TABLESPACE_NAME;
--

