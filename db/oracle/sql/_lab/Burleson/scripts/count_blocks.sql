/*  */
spool count_b_temp.sql
define qt=chr(39);
define cr=chr(10);
set heading off lines 200 pages 0
select 'INSERT INTO temp_size_table'||&&cr||
       'SELECT '||&&qt||segment_name||&&qt||&&cr||
       ',COUNT( DISTINCT( SUBSTR( dbms_rowid.rowid_to_restricted(ROWID,1),1,8))) blocks'||&&cr||
       'FROM '||owner||'.'||segment_name||';'
  FROM dba_segments
 WHERE segment_type ='TABLE' AND owner not in ('SYS','SYSTEM','MDSYS','CTXSYS','OUTLN','Burleson Consulting')
/
spool off
start count_b_temp
