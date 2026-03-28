-- Start of DDL Script for Table CTAS_CHANGE_BACKUP.CTAS_CB_OPER_LOG
-- Generated 20/3/2009 11:10:39 from CTAS_CHANGE_BACKUP@DEV

CREATE TABLE ctas_change_backup.ctas_cb_oper_log
    (cb_list_id                     NUMBER(5,0) NOT NULL,
    log_id                         NUMBER(10,0),
    log_is_err                     CHAR(1) DEFAULT 'N' NOT NULL,
    log_messages                   VARCHAR2(2000),
    log_ora_err                    VARCHAR2(5),
    log_ora_err_line               VARCHAR2(5),
    log_step                       VARCHAR2(500),
    log_date                       DATE NOT NULL,
    log_os_user                    VARCHAR2(150) NOT NULL,
    log_user_ip                    VARCHAR2(15) NOT NULL,
    log_machine_name               VARCHAR2(200))
  PCTFREE     10
  INITRANS    1
  MAXTRANS    255
  TABLESPACE  change_backup_01
  STORAGE   (
    INITIAL     65536
    MINEXTENTS  1
    MAXEXTENTS  2147483645
  )
  NOCACHE
  MONITORING
/





-- Constraints for CTAS_CHANGE_BACKUP.CTAS_CB_OPER_LOG



-- Comments for CTAS_CHANGE_BACKUP.CTAS_CB_OPER_LOG

COMMENT ON TABLE ctas_change_backup.ctas_cb_oper_log IS 'Lists a detailed log of the CTAS BACKUP operations.'
/
COMMENT ON COLUMN ctas_change_backup.ctas_cb_oper_log.log_is_err IS 'Tells whether it''s a error message or a normal operational information'
/
COMMENT ON COLUMN ctas_change_backup.ctas_cb_oper_log.log_step IS 'Tells wich procedure task caused the error'
/

-- End of DDL Script for Table CTAS_CHANGE_BACKUP.CTAS_CB_OPER_LOG

-- Foreign Key
ALTER TABLE ctas_change_backup.ctas_cb_oper_log
ADD CONSTRAINT fk_list_id FOREIGN KEY (cb_list_id)
REFERENCES CTAS_CHANGE_BACKUP.ctas_cb_list (cb_list_id)
/
-- End of DDL script for Foreign Key(s)