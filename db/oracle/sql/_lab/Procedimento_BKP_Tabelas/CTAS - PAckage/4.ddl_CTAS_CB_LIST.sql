-- Start of DDL Script for Table CTAS_CHANGE_BACKUP.CTAS_CB_LIST
-- Generated 20/3/2009 11:09:21 from CTAS_CHANGE_BACKUP@DEV

CREATE TABLE ctas_change_backup.ctas_cb_list
    (cb_list_id                     NUMBER(5,0) NOT NULL,
    cb_change_number               NUMBER(5,0) NOT NULL,
    cb_version_id                  NUMBER(2,0) NOT NULL,
    cb_table_owner                 VARCHAR2(30) NOT NULL,
    cb_table_name                  VARCHAR2(30) NOT NULL,
    cd_backup_date                 DATE NOT NULL,
    cb_exp_date                    DATE,
    cb_table_metadata              CLOB,
    cb_os_user                     VARCHAR2(150) NOT NULL,
    cb_user_ip                     VARCHAR2(15) NOT NULL,
    cb_machine_name                VARCHAR2(200),
    cb_where_clause                VARCHAR2(2000),
    cb_partition_name              VARCHAR2(2000),
    cb_is_unrecoverable            CHAR(1) DEFAULT 'Y',
    cb_del_flag                    CHAR(1) DEFAULT 'N',
    cb_update_dt                   DATE,
    cb_update_usr                  VARCHAR2(150),
    cb_physc_table                 VARCHAR2(30))
  PCTFREE     10
  INITRANS    1
  MAXTRANS    255
  TABLESPACE  change_backup_01
  STORAGE   (
    INITIAL     10485760
    MINEXTENTS  1
    MAXEXTENTS  2147483645
  )
 
/





-- Indexes for CTAS_CHANGE_BACKUP.CTAS_CB_LIST

CREATE UNIQUE INDEX ctas_change_backup.idx_change_version ON ctas_change_backup.ctas_cb_list
  (
    cb_change_number                ASC,
    cb_version_id                   ASC
  )
  PCTFREE     10
  INITRANS    2
  MAXTRANS    255
  TABLESPACE  change_backup_01
  STORAGE   (
    INITIAL     65536
    MINEXTENTS  1
    MAXEXTENTS  2147483645
  )
/



-- Constraints for CTAS_CHANGE_BACKUP.CTAS_CB_LIST

ALTER TABLE ctas_change_backup.ctas_cb_list
ADD CONSTRAINT pk_list_id PRIMARY KEY (cb_list_id)
USING INDEX
  PCTFREE     10
  INITRANS    2
  MAXTRANS    255
  TABLESPACE  change_backup_01
  STORAGE   (
    INITIAL     65536
    MINEXTENTS  1
    MAXEXTENTS  2147483645
  )
/


-- Comments for CTAS_CHANGE_BACKUP.CTAS_CB_LIST

COMMENT ON TABLE ctas_change_backup.ctas_cb_list IS '"CREATE TABLE AS " CHANGE BACKUP LIST'
/
COMMENT ON COLUMN ctas_change_backup.ctas_cb_list.cb_change_number IS 'Change Number (See Change Control Sheet)'
/
COMMENT ON COLUMN ctas_change_backup.ctas_cb_list.cb_del_flag IS 'If Y the package will ignore the record'
/
COMMENT ON COLUMN ctas_change_backup.ctas_cb_list.cb_exp_date IS 'After this date the table may be dropped if space is required to create a new backup'
/
COMMENT ON COLUMN ctas_change_backup.ctas_cb_list.cb_is_unrecoverable IS 'If N specified Oracle causes the CTAS stetament to generate REDO LOG information.'
/
COMMENT ON COLUMN ctas_change_backup.ctas_cb_list.cb_list_id IS 'Table Id Index (Internal Only)'
/
COMMENT ON COLUMN ctas_change_backup.ctas_cb_list.cb_partition_name IS 'Partiotion name (Only Partition Backups)'
/
COMMENT ON COLUMN ctas_change_backup.ctas_cb_list.cb_table_metadata IS 'Holds table''s metadata'
/
COMMENT ON COLUMN ctas_change_backup.ctas_cb_list.cb_version_id IS 'Sequencial number used when a change fails and then reapplied'
/
COMMENT ON COLUMN ctas_change_backup.ctas_cb_list.cb_where_clause IS 'Allows users to restric data retrived from the original table. USAGE: "WHERE FIELD1= AND FIELD2 = ..."'
/
COMMENT ON COLUMN ctas_change_backup.ctas_cb_list.cd_backup_date IS 'Dates the backup creation'
/

-- End of DDL Script for Table CTAS_CHANGE_BACKUP.CTAS_CB_LIST
