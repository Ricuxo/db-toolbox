set linesize 132
set pagesize 999

col username for a23
col dba for a3
col status for a7
col default_tablespace for a20
col profile for a18
col pwd_verify format a20
col plt for a3
col fla for a3
col rum for a3
col pgt for a3
col pwd_lok for a7

with profile_detail as
(
select
dbp.profile,
dbp.resource_name,
decode(dbp.limit,'DEFAULT',def.limit,'NULL','','UNLIMITED','',dbp.limit) limit
from
dba_profiles dbp,
(
select
def.resource_name,
decode(def.limit,'NULL','','UNLIMITED','',def.limit) limit
from
dba_profiles def
where profile = 'DEFAULT'
) def
where 1=1
and dbp.resource_name = def.resource_name
order by 2,1
)
select
dbu.username,
decode(dba.grantee,null,'NO','YES') dba,
replace(
replace(
replace(
replace(dbu.account_status,'LOCKED','LOK'),
'EXPIRED','EXP'),
'(GRACE)','(GR)'),
' & ','&'
) status,
-- dbu.lock_date,
-- dbu.expiry_date,
-- dbu.default_tablespace,
dbu.profile,
pwd.limit "PWD_VERIFY",
plt.limit "PLT",
fla.limit "FLA",
rum.limit "RUM",
pgt.limit "PGT",
plk.limit "PWD_LOK"
from
dba_users dbu,
( select grantee from dba_role_privs where granted_role = 'DBA' ) dba,
profile_detail pwd,
profile_detail plt,
profile_detail fla,
profile_detail rum,
profile_detail pgt,
profile_detail plk
where 1=1
and pwd.profile=dbu.profile
and pwd.resource_name = 'PASSWORD_VERIFY_FUNCTION'
and plt.profile=dbu.profile
and plt.resource_name = 'PASSWORD_LIFE_TIME'
and fla.profile=dbu.profile
and fla.resource_name = 'FAILED_LOGIN_ATTEMPTS'
and rum.profile=dbu.profile
and rum.resource_name = 'PASSWORD_REUSE_MAX'
and pgt.profile=dbu.profile
and pgt.resource_name = 'PASSWORD_GRACE_TIME'
and plk.profile=dbu.profile
and plk.resource_name = 'PASSWORD_LOCK_TIME'
and dbu.username = dba.grantee(+)
order by 1
/


---The PLT column shows the password life time – currently 180 days.
---The FLA column shows the Failed Login Attempts allowed before the account is locked.
---The RUM column shows the Password Reuse Max.
---The PGT column shows the Password Grace Time.
---The PWD_LOK column shows the Password Lock Time.