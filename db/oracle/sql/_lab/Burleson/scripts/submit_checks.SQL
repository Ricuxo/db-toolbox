/*  */
create or replace procedure submit_checks(owner_name IN VARCHAR2) is
begin
dba_utilities.check_tables(owner_name,10,10000); 
dba_utilities.flush_it(85,100);
end;
/
