/*  */
col text format a80 word_wrapped
col name format a10
col name format a32
set lines 200
select owner, name, text
from dba_source
where
(upper(text) like '%TRUNCATE TABLE%'
or upper(text) like '%DROP TABLE%'
or upper(text) like '%DROP INDEX%') and text not like ('%--%')
and owner !='SYS'
/
