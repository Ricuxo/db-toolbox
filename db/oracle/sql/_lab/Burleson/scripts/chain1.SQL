/*  */
/*  Create a table that will show row chaining and/or row migration.
**  Analyze the table to determine the chaining of the table.
*/
drop table chain1;

create table chain1
(col1 varchar2(255),
 col2 varchar2(255),
 col3 varchar2(255),
 col4 varchar2(255),
 col5 varchar2(255),
 col6 varchar2(255),
 col7 varchar2(255)
 )
 PCTFREE 10,
 PCTUSED 40;
 declare ctr int := 0;
 begin
 while ctr < 1000
 loop
        insert into chain1 (col1) values (to_char(ctr));
        commit;
        ctr := ctr + 1;
 end loop;
 end;
/
declare
t varchar2(250) := '123456789012345';
ctr int := 0;
begin
while ctr < 4
loop
   t := t || t;
   ctr := ctr + 1;
end loop;
ctr := 0;
update chain1 set col2 = t, col3 = t, col4 = t, col5 = t,
  col6 = t, col7 = t;

end;
/
analyze table chain1 compute statistics;
drop view chain1_view;
create view chain1_view as select col1 from chain1;


