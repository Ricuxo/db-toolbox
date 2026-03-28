/*  */
col owner format a15 heading 'Temp Table|Owner'
col table_name heading 'Temp Table Name'
col temporary format a5 heading 'Temp?'
@title80 'Global Temporary Tables'
spool rep_out\&db\gtt_rep
select owner,table_name,temporary from dba_tables where temporary='Y'
/
spool off
clear col
ttitle off
