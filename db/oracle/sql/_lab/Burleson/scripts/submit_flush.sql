/*  */
var x number;
begin
dbms_job.submit(:x,'begin flush_it(85,10); end;',sysdate,'sysdate+1/8');
commit;
end;
/
