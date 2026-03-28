/*  */
drop table store_table;
create table store_table 
(data_item INTEGER, length_of_item INTEGER, 
storage_type VARCHAR2(30), owning_dept NUMBER, storage_date DATE)
 partition by range (storage_date)
 subpartition by hash (data_item)
 subpartitions 4
 store in (dbautil_data)
 (partition q1_2001 values less than (to_date('01-apr-2001','dd-mon-yyyy'))
  storage (initial 100k next 100k pctincrease 0),
 partition q2_2001 values less than (to_date('01-jul-2001','dd-mon-yyyy'))
  storage (initial 200k next 200k pctincrease 0),
 partition q3_2001 values less than (to_date('01-oct-2001','dd-mon-yyyy'))
  storage (initial 150k next 150k pctincrease 0)
   (subpartition q3_2001_s1 TABLESPACE dbautil_index,
   subpartition q3_2001_s2 TABLESPACE dbautil_index),
 partition q4_2001 values less than (to_date('01-jan-2002','dd-mon-yyyy'))
  storage (initial 50k next 50k pctincrease 0));
