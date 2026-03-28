---Verificar contenção de sequence
select sh.sql_id,to_char(st.sql_text),count(*)
from dba_hist_active_sess_history sh
join dba_hist_sqltext st
 on sh.sql_id=st.sql_id
where st.sql_text like '%NEXTVAL%'
 and (event like '%cache lock%' or event like 'gc current block %-way')
group by sh.sql_id,to_char(st.sql_text)
order by count(*) desc;



select tabs.table_name,
  trigs.trigger_name,
  seqs.sequence_name,
  seqs.CACHE_SIZE
from dba_tables tabs
join dba_triggers trigs
  on trigs.table_owner = tabs.owner
  and trigs.table_name = tabs.table_name
join dba_dependencies deps
  on deps.owner = trigs.owner
  and deps.name = trigs.trigger_name
join dba_sequences seqs
  on seqs.sequence_owner = deps.referenced_owner
  and seqs.sequence_name = deps.referenced_name
where tabs.owner not in (select username from dba_users where ORACLE_MAINTAINED='Y')
and tabs.table_name='CAD_PSS_FIS_RCP_CRD'
order by 4 desc;