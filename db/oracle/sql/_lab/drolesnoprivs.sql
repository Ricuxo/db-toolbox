set pagesize 1000

select role
  from dba_roles dr
       -- roles assigned to roles
 where not exists (select 1
                     from dba_role_privs drp
                    where drp.grantee = dr.role)
       -- db objects to roles
   and not exists (select 1
                     from dba_tab_privs dtp
                    where dtp.grantee = dr.role)
       -- sys privs to roles
   and not exists (select 1
                     from dba_sys_privs dsp
                   where dsp.grantee = dr.role)
   and role not like 'FOSA%'
   -- deafult Oracle roles
   and role not in ('AQ_USER_ROLE','DELETE_CATALOG_ROLE','EJBCLIENT','GATHER_SYSTEM_STATISTICS'
                   ,'GLOBAL_AQ_USER_ROLE','JAVAIDPRIV','JAVAUSERPRIV','JAVA_ADMIN','CONNECT'
                   ,'JAVA_DEPLOY','WM_ADMIN_ROLE','JMXSERVER','XDBADMIN','XDB_SET_INVOKER'
                   ,'EXECUTE_CATALOG_ROLE','EXP_FULL_DATABASE','HS_ADMIN_ROLE','IMP_FULL_DATABASE'
                   ,'XDB_WEBSERVICES','XDB_WEBSERVICES_OVER_HTTP','XDB_WEBSERVICES_WITH_PUBLIC'
                   ,'PLUSTRACE','RESOURCE','SCHEDULER_ADMIN','SELECT_CATALOG_ROLE','OEM_ADVISOR'
                   ,'DATAPUMP_EXP_FULL_DATABASE','DATAPUMP_IMP_FULL_DATABASE'
                   ,'HS_ADMIN_EXECUTE_ROLE','HS_ADMIN_SELECT_ROLE','AUTHENTICATEDUSER')
/