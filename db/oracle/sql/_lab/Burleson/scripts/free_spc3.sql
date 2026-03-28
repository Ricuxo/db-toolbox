/*  */
select tablespace_name,
       total_space,
       total_space-free_space,
       free_space,
       (free_space/total_space)*100,
       ((total_space-free_space)/total_space)*100,
       num_files
  from (select tablespace_name,
               sum(bytes/1024) total_space,
               count(*) num_files
          from sys.dba_data_files
        group by tablespace_name),
       (select tablespace_name TS_NAME,
               sum(bytes/1024) free_space
          from sys.dba_free_space
        group by tablespace_name)
 where tablespace_name = TS_NAME
 order by 6,1
/
