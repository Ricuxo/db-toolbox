--select * from table( dbms_xplan.display_cursor('&1', &2, format=>'ADVANCED') );
select * from table( dbms_xplan.display_cursor('&1', &2) );