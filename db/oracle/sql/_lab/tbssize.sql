set pagesize 999
set linesize 160

column tablespace_name format a30
column tablespace_size_mb format 9,999,999
column free_size_mb format 9,999,999
column tablespace_size_gb format 9,999
column free_size_gb format 9,999
column free_percent format a20

col name for a20

SELECT d.status "Status"
     , d.tablespace_name "Name"
	 , d.contents "Type"
	 , d.extent_management "ExtManag"
	 , TO_CHAR(NVL(a.bytes / 1024 / 1024, 0),'99,999,990.900') "Size (M)"
	 , TO_CHAR(NVL(t.bytes,0)/1024/1024,'99999,999.999') ||'/'||TO_CHAR(NVL(a.bytes/1024/1024, 0),'99999,999.999') "Used (M)"
	 , TO_CHAR(NVL(t.bytes / a.bytes * 100, 0), '990.00') "Used %"
  FROM sys.dba_tablespaces d
     , (select tablespace_name, sum(bytes) bytes
	      from dba_temp_files 
		 group by tablespace_name) a
     , (select tablespace_name
	         , sum(bytes_cached) bytes
	      from v$temp_extent_pool
		 group by tablespace_name) t
 WHERE d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = t.tablespace_name(+)
   AND d.extent_management like 'LOCAL' AND d.contents like 'TEMPORARY'
/

select b.tablespace_name
     , b.tablespace_size_mb
     , round(sum(nvl(fs.bytes,0))/1024/1024, 2) free_size_mb
     , b.tablespace_size_gb
     , round(sum(nvl(fs.bytes,0))/1024/1024/1024, 2) free_size_gb
     , case when round(sum(nvl(fs.bytes,0))/1024/1024/b.tablespace_size_mb *100, 2) > 3
            then to_char(round(sum(nvl(fs.bytes,0))/1024/1024/b.tablespace_size_mb *100, 2), '900.99')|| ' '
            else to_char(round(sum(nvl(fs.bytes,0))/1024/1024/b.tablespace_size_mb *100, 2), '900.99')|| ' <======='
       end free_percent
  from dba_free_space fs
     , (select tablespace_name
             , round(sum(bytes)/1024/1024, 2) tablespace_size_mb
             , round(sum(bytes)/1024/1024/1024, 2) tablespace_size_gb
          from dba_data_files
         group by tablespace_name
       ) b
 where fs.tablespace_name = b.tablespace_name
   and fs.tablespace_name = nvl('&TBSNAME', fs.tablespace_name)
   and b.tablespace_name = fs.tablespace_name
 group by b.tablespace_name
        , b.tablespace_size_mb
        , b.tablespace_size_gb
 order by free_percent
/