/*  */
AULTDB1:
AULTDB1:select
  2     'alter session set hash_area_size='||trunc(sum(bytes)*1.6)||';'
  3  from
  4     dba_segments
  5  where
  6     segment_name = upper('&1');
Enter value for 1: 

alter session set hash_area_size=;                                              
AULTDB1:spool off;
