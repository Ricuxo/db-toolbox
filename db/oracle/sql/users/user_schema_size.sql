select owner,sum(bytes)/1024/1024/1024 as "Size in GB"
from dba_segments where owner= UPPER('&schema_name')
group by owner;



-- col owner for a30
-- set lines 500
-- select owner,sum(bytes)/1024/1024/1024 as "Size in GB"
-- from dba_segments group by owner order by 1;


--select segment_type,sum(bytes)/1024/1024/1024 as "Size in GB"
--from dba_segments where owner= UPPER('&schema_name')
--group by segment_type;


--select owner,round(sum(bytes)/1024/1024/1024,2) as "Size in GB"
--from dba_segments where owner NOT IN (
--'ANONYMOUS','APEX_040200','APEX_PUBLIC_USER','APPQOSSYS','AUDSYS','CTXSYS','DBSNMP','DIP','DVF','DVSYS','EXFSYS','FLOWS_FILES','GSMADMIN_INTERNAL','GSMCATUSER','GSMUSER','LBACSYS','MDDATA','MDSYS','OJVMSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDSYS','ORDPLUGINS','OUTLN','SI_INFORMTN_SCHEMA','SCOTT','SYS','SYSDG','SYSKM','SYSMAN','SYSTEM','SYSBACKUP','SPATIAL_CSW_ADMIN_USR','SPATIAL_WFS_ADMIN_USR','WKPROXY','WKSYS','WK_TEST','WMSYS','XDB','XS$NULL','REMOTE_SCHEDULER_AGENT')
--GROUP BY owner
--ORDER BY owner
--/