/*  */
col column_name format a15 heading 'Column|Name'
col segment_name format a26 heading 'Segment|Name'
col index_name format a26 heading 'Index|Name'
col owner format a15 heading 'Owner'
col table_name format a22 heading 'Table|Name'
col in_row format a3 heading 'In|Row'
set lines 132 pages 50
start title132 'Database Lob Column Data'
spool rep_out\&db\lob_col
select owner,table_name,column_name,segment_name,index_name,in_row from dba_lobs
where owner not in ('SYS','SYSTEM','PRECISE','MAULT','PATROL','QDBA','OUTLN','XDB','WMSYS','MDSYS','CTXSYS','ODM','SYSMAN')
/
spool off
set lines 80 pages 22
ttitle off
