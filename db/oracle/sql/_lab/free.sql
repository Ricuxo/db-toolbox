select tablespace_name,bytes/1024/1024 from dba_free_space
where bytes/1024/1024 >= 1
and tablespace_name='&TBS'
order by 2 desc
/
