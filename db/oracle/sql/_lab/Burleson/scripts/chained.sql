/*  */
/*  Create a table that will show row chaining and/or row migration.
**  Analyze the table to determine the chaining of the table.
*/
drop table chained;

create table chained
(col1 varchar2(255),
 col2 varchar2(255),
 col3 varchar2(255),
 col4 varchar2(255),
 col5 varchar2(255),
 col6 varchar2(255),
 col7 varchar2(255)
 )
 PCTFREE 80,
 PCTUSED 20;
 declare ctr int := 0;
 begin
 while ctr < 1000
 loop
        insert into chained (col1) values (to_char(ctr));
        commit;
        ctr := ctr + 1;
 end loop;
 end;
/
exit

