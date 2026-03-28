/*  */
var x number;
begin
dbms_job.submit(:x,'begin dba_utilities.just_statistics(FALSE); end;',sysdate,'sysdate+1/24');
commit;
end;
/
