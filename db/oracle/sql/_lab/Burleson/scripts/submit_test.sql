/*  */
var x number;
begin
dbms_job.submit(:x,'begin submit_checks; end;',trunc(sysdate),'trunc(sysdate+1)');
commit;
end;
/
