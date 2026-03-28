-- Start of DDL Script for User CTAS_CHANGE_BACKUP
-- Generated 6/2/2009 13:58:59 from SYSTEM@DEV

CREATE USER ctas_change_backup
IDENTIFIED BY refle7con
DEFAULT TABLESPACE CHANGE_BACKUP_01
ACCOUNT LOCK
QUOTA UNLIMITED ON CHANGE_BACKUP_01
/
GRANT CONNECT TO ctas_change_backup
/
GRANT RESOURCE TO ctas_change_backup
/
ALTER USER ctas_change_backup DEFAULT ROLE ALL
/
GRANT SELECT ON dba_extents TO ctas_change_backup
/
GRANT SELECT ON dba_free_space TO ctas_change_backup
/
GRANT SELECT ON dba_segments TO ctas_change_backup
/
GRANT SELECT ON v_$parameter TO ctas_change_backup
/
GRANT SELECT ON v_$spparameter TO ctas_change_backup
/


-- End of DDL Script for User CTAS_CHANGE_BACKUP
