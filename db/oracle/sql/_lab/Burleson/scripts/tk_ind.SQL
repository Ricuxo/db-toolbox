/*  */


create unique index tkp_exp_index
on tkp_example(
username,
default_tablespace,
temporary_tablespace) tablespace cnet_indexes;

create unique index tkp_exp_index2
on tkp_example(
temporary_tablespace,
username,
default_tablespace) tablespace cnet_indexes;

create unique index tkp_exp_index3
on tkp_example(
default_tablespace,
temporary_tablespace,
username) tablespace cnet_indexes;

create unique index tkp_exp2_index2 on
tkp_example2(
owner,
tablespace_name,
object_name,
object_type) tablespace cnet_indexes;


 create unique index tkp_exp2_index on
tkp_example2(
 owner,
object_name,
object_type) tablespace cnet_indexes;

create unique index tkp_exp2_index3 on
tkp_example2(
tablespace_name,
owner,
object_name,
object_type) tablespace cnet_indexes;
