/*  */
create table stat_temp storage (initial 1m next 1m) as select * from index_stats
 ;                                                                              
truncate table stat_temp;                                                       
