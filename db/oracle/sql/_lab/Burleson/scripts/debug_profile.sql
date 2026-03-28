/*  */
set linesize 155;
set pagesize 200;
set verify off;

col Profile format a20;
col Level format a14;
col Value format a10;
col App format a3;
col Responsibility format a30;
col USER format a8;
col UPDATED_BY format a8;
start title132 'Debug Profiles'
spool rep_out\&&db\debug_prof

select fpo.profile_option_name Profile,
       fpov.profile_option_value Value,
       decode(fpov.level_id,10001,
                'SITE',10002,
                'APPLICATION',10003,
                'RESPONSIBILITY',
                10004,'USER')"LEVEL",
       fa.application_short_name App,
       fr.responsibility_name Responsibility,
       fu.user_name "USER"
from fnd_profile_option_values fpov,
fnd_profile_options fpo, 
fnd_application fa, 
fnd_responsibility_vl fr,
fnd_user fu,
fnd_logins fl
where fpo.profile_option_id=fpov.profile_option_id
and fa.application_id(+)=fpov.level_value
and fr.application_id(+)=fpov.level_value_application_id
and fr.responsibility_id(+)=fpov.level_value
and fu.user_id(+)=fpov.level_value
and fl.login_id(+) = fpov.LAST_UPDATE_LOGIN
and fpo.profile_option_name like 'ONT_DEBUG_LEVEL'
order by 1,3
/
spool off
set lines 80 pages 22 verify on
clear columns
ttitle off

