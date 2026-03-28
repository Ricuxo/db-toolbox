/*  */
column shared_pool_used format 9,999.99
column shared_pool_size format 9,999.99
column shared_pool_avail format 9,999.99
column avail_pool_pct format 999.99
@title80 'Shared Pool Summary'
spool rep_out\&db\shared_pool
 select 
least(decode(b.value,'%M',to_number(substr(b.value(1,instr(b.value,'M')-1)))), sum(a.bytes)/(1024*1024))  shared_pool_used,decode(b.value,'%M',to_number(substr(b.value(1,instr(b.value,'M')-1)))) shared_pool_size,greatest(max(decode(b.value,'%M',to_number(substr(b.value(1,instr(b.value,'M')-1)))),sum(a.bytes)/(1024*1024))-(sum(a.bytes)/(1024*1024)) shared_pool_avail,((sum(a.bytes)/(1024*1024))/(max(decode(b.value,'%M',to_number(substr(b.value(1,instr(b.value,'M')-1))))*(1024*1024))/(1024*1024)))*100 full_pool_pct
   from v$sgastat a, v$parameter b 
 where (a.pool='shared pool'
 and a.name not in ('free memory'))
 and
 b.name='shared_pool_size';
rem SELECT 
rem		SUM(a.BYTES)/1048576 pool_used,
rem                max(b.value)/(1024*1024) shared_pool_size,
rem                (max(b.value)/(1024*1024))-(sum(a.bytes)/(1024*1024)) shared_pool_avail,
rem                (sum(a.bytes)/max(b.value))*100 avail_pool_pct
rem	FROM  
rem		v$sgastat a, v$parameter b 
rem	WHERE 
rem		a.name in ( 
rem		'reserved stopper',             
rem		'table definiti',                  
rem		'dictionary cache',           
rem		'library cache',              
rem		'sql area',
rem		'PL/SQL DIANA',
rem		'SEQ S.O.') and
rem                b.name='shared_pool_size';
spool off
ttitle off
