-- Start of DDL Script for Package Body CTAS_CHANGE_BACKUP.PKG_CTAS_BACKUP
-- Generated 12/09/2012 17:24:33 from CTAS_CHANGE_BACKUP@TESTE_THIAGO

CREATE OR REPLACE 
PACKAGE                    ctas_change_backup.pkg_ctas_backup
AUTHID CURRENT_USER
  IS
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

--   variable_name   datatype;


  PROCEDURE backup_table
     ( p_change_number      IN ctas_change_backup.ctas_cb_list.cb_change_number%TYPE,
       p_owner              IN ctas_change_backup.ctas_cb_list.cb_table_owner%TYPE,
       p_table_name         IN ctas_change_backup.ctas_cb_list.cb_table_name%TYPE,
       p_exp_date           IN ctas_change_backup.ctas_cb_list.cb_exp_date%TYPE,
       p_is_unrecoverable   IN ctas_change_backup.ctas_cb_list.cb_is_unrecoverable%TYPE DEFAULT 'Y',
       p_where_clause       IN ctas_change_backup.ctas_cb_list.cb_where_clause%TYPE DEFAULT NULL,
       p_partition_name     IN ctas_change_backup.ctas_cb_list.cb_partition_name%TYPE DEFAULT NULL
     );

   PROCEDURE drop_backup
     ( p_change_number  IN ctas_change_backup.ctas_cb_list.cb_change_number%TYPE,
       p_version_id     IN ctas_change_backup.ctas_cb_list.cb_version_id%TYPE
     );

   FUNCTION list_expired RETURN SYS_REFCURSOR;

   FUNCTION list_available RETURN SYS_REFCURSOR;

   PROCEDURE help;

  FUNCTION show_metadata   ( p_change_number  IN ctas_change_backup.ctas_cb_list.cb_change_number%TYPE,
                             p_version_id     IN ctas_change_backup.ctas_cb_list.cb_version_id%TYPE
                           )
  RETURN SYS_REFCURSOR;
END; -- Package spec
/


CREATE OR REPLACE 
PACKAGE BODY                    ctas_change_backup.pkg_ctas_backup
IS

  --Constantes Log Messages
  cons_log_msg_DROP_EXP_TABLE    CONSTANT   VARCHAR2(200)   := 'TABLE DROPPED SUCCESSFULLY DUE EXPIRATION';
  cons_log_err_DROP_COMMAND      CONSTANT   VARCHAR2(200)   := 'TABLE DROPPED SUCCESSFULLY DUE DROP COMMAND';
  cons_log_msg_DROP_COMMAND      CONSTANT   VARCHAR2(200)   := 'TABLE DROPPED SUCCESSFULLY DUE DROP COMMAND';
  cons_BACKUPUSER                CONSTANT   VARCHAR2(100)   := 'CTAS_CHANGE_BACKUP';




 PROCEDURE drop_expired (p_log_step IN VARCHAR2)
  IS

    --Selecionando registros de tabelas expirados
    CURSOR cur_expired_list
        IS SELECT cb_change_number, cb_version_id, cb_exp_date
           FROM ctas_change_backup.ctas_cb_list
           WHERE cb_exp_date < sysdate
           AND cb_del_flag = 'N';

    v_log_id    NUMBER(10,0);

    BEGIN
    FOR  x IN cur_expired_list LOOP

        BEGIN
        --Atualizacao devido a bugs encontrados em 12/09/2012

        drop_backup(x.cb_change_number,x.cb_version_id);
        dbms_output.put_line('*********************************************************************' );--NULL;
        dbms_output.put_line('* BACKUP DA CHANGE ' || x.cb_change_number || ' - VERSAO ' ||  x.cb_version_id);
        dbms_output.put_line('* ELIMINADO PARA LIBERACAO DE ESPACO - DATA EXPIRACAO:' || TO_CHAR(x.cb_exp_date,'DD/MM/YYYY'));--NULL;
        dbms_output.put_line('*********************************************************************' );--NULL;

        /*
            EXECUTE IMMEDIATE 'DROP TABLE ' || cons_BACKUPUSER || '.' || x.cb_physc_table;

            UPDATE ctas_change_backup.ctas_cb_list
            SET cb_del_flag     = 'Y',
                cb_update_dt    = sysdate,
                cb_update_usr   = sys_context('USERENV', 'OS_USER')
            WHERE cb_list_id = x.cb_list_id;


            SELECT seq_log_id.NEXTVAL INTO v_log_id FROM dual;

            INSERT INTO ctas_change_backup.ctas_cb_oper_log
            VALUES(x.cb_list_id, v_log_id , 'N', cons_log_msg_DROP_EXP_TABLE,
                   NULL, NULL, p_log_step, SYSDATE, sys_context('USERENV', 'OS_USER'),
                   sys_context('USERENV','IP_ADDRESS'), sys_context('USERENV','HOST'));
            COMMIT;*/
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
    END LOOP;
  END;

  --Faz o calculo de paralelismo
  FUNCTION calc_parallel(p_owner              IN ctas_change_backup.ctas_cb_list.cb_table_owner%TYPE,
                         p_table_name         IN ctas_change_backup.ctas_cb_list.cb_table_name%TYPE)
  RETURN NUMBER
  IS
    v_RESULT            NUMBER;
    v_cpu_count         NUMBER;
    v_datafile_count    NUMBER;
    v_teste             VARCHAR2(6);

  BEGIN
    --Buscando o CPU COUNT
    SELECT ISSPECIFIED INTO v_teste FROM v$spparameter WHERE name = 'cpu_count';
    IF v_teste = 'TRUE' THEN --Verificando se o banco está em modo SPFILE
        SELECT value INTO v_cpu_count
        FROM v$spparameter
        WHERE name = 'cpu_count';
    ELSE --
        SELECT value INTO v_cpu_count
        FROM v$parameter
        WHERE name = 'cpu_count';
    END IF;
    --Buscando o número de data files
    SELECT NVL(COUNT(DISTINCT file_id),0) INTO v_datafile_count
    FROM sys.dba_extents
    WHERE owner         = p_owner
    AND segment_name    = p_table_name;

    IF (v_datafile_count * 2) > v_cpu_count THEN
        RETURN v_cpu_count;
    ELSE
        RETURN (v_datafile_count * 2);
    END IF;

  END;


  --Verifica espaço livre no tablespace.
  FUNCTION ts_free_space
    ( p_tablespace_name  IN  VARCHAR2)
  RETURN NUMBER IS

    v_RESULT NUMBER(10,2):= 0;

  BEGIN

    SELECT SUM(bytes / 1024 / 1024) MB INTO v_RESULT
    FROM sys.dba_free_space
    WHERE tablespace_name = UPPER(p_tablespace_name);

    RETURN v_RESULT;

  END;

  --Verifica o tamanho da tabela
  FUNCTION table_size
    ( p_table_owner  IN  VARCHAR2,
      p_table_name  IN  VARCHAR2
    )
  RETURN NUMBER IS

    v_RESULT NUMBER(10,2):= 0;

  BEGIN

    SELECT sum(bytes)/1024/1024 MB INTO v_RESULT
    FROM sys.dba_segments
    WHERE owner         = UPPER(p_table_owner)
    AND segment_name    = UPPER(p_table_name);

    RETURN v_RESULT;

  END;

--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
-- Enter procedure, function bodies as shown below

  PROCEDURE backup_table
     ( p_change_number      IN ctas_change_backup.ctas_cb_list.cb_change_number%TYPE,
       p_owner              IN ctas_change_backup.ctas_cb_list.cb_table_owner%TYPE,
       p_table_name         IN ctas_change_backup.ctas_cb_list.cb_table_name%TYPE,
       p_exp_date           IN ctas_change_backup.ctas_cb_list.cb_exp_date%TYPE,
       p_is_unrecoverable   IN ctas_change_backup.ctas_cb_list.cb_is_unrecoverable%TYPE DEFAULT 'Y',
       p_where_clause       IN ctas_change_backup.ctas_cb_list.cb_where_clause%TYPE DEFAULT NULL,
       p_partition_name     IN ctas_change_backup.ctas_cb_list.cb_partition_name%TYPE DEFAULT NULL
     )
  IS
  --Constru¿Æo do execute immediate
  cons_CTAS             CONSTANT VARCHAR2(100)           := 'CREATE TABLE ';
  cons_TABLESPACE       CONSTANT VARCHAR2(100)           := ' TABLESPACE CHANGE_BACKUP_01 ';
  cons_TABLESPACE_NAME  CONSTANT VARCHAR2(100)           := 'CHANGE_BACKUP_01';
  cons_UNRECOVERABLE    CONSTANT VARCHAR2(100)           := ' UNRECOVERABLE ';


  --Lista de possiveis exceçoes
  err_SPACE_INSUFFICIENT    EXCEPTION;
  err_tableNOTexists        EXCEPTION;
  err_tableSpaceNOTexists   EXCEPTION;


  --Variaveis
  v_list_id                 ctas_change_backup.ctas_cb_list.cb_list_id%TYPE;
  v_version_id              ctas_change_backup.ctas_cb_list.cb_version_id%TYPE;
  v_SQL                     VARCHAR2(2000);
  v_METADATA                LONG;
  v_physical_table_name     VARCHAR(30);
  BEGIN

    --Essa chamada irá dropar todas os backups expirados
    drop_expired('Backup Table');
    --Verificando espaço disponível
    IF  ts_free_space(cons_TABLESPACE_NAME) < table_size(UPPER(p_owner), UPPER(p_table_name)) THEN
        RAISE err_SPACE_INSUFFICIENT;
    END IF;
        --Iniciando CTAS
        BEGIN
            --list id
            SELECT ctas_change_backup.seq_list_id.NEXTVAL INTO v_list_id FROM DUAL;

            --Descobrindo a versão do último backup, se existir
            SELECT MAX(cb_version_id) INTO v_version_id
            FROM ctas_change_backup.ctas_cb_list
            WHERE cb_change_number = p_change_number;
            --Próxima versão
            v_version_id := NVL(v_version_id,0) + 1;

            --Gerando o nome da físico da tabela de backup
            v_physical_table_name := SUBSTR('C' || TO_CHAR(p_change_number) || 'V' || v_version_id || '_' || UPPER(p_table_name),1,30); --Nome da tabela

            v_SQL := 'CREATE TABLE ' || cons_BACKUPUSER || '.' ;
            v_SQL := v_SQL || v_physical_table_name;
            v_SQL := v_SQL || ' TABLESPACE ' || cons_TABLESPACE_NAME ; --tablespace
            V_SQL := v_SQL || ' PARALLEL (DEGREE ' || TO_CHAR(calc_parallel(UPPER(p_owner),UPPER(p_table_name))) || ') ';
            IF p_is_unrecoverable = 'Y' THEN
                v_SQL := v_SQL || cons_UNRECOVERABLE;
            END IF;

            --Verificando a existência do parametro de particao
            IF p_partition_name IS NOT NULL THEN
                v_SQL := v_SQL || ' AS SELECT * FROM ' || UPPER(p_owner) || '.' || UPPER(p_table_name) || ' PARTITION(' || p_partition_name || ') ' ;
            ELSE
                v_SQL := v_SQL || ' AS SELECT /*+ PARALLEL (A, ' || TO_CHAR(calc_parallel(UPPER(p_owner),UPPER(p_table_name))) || ')*/ * FROM ' || UPPER(p_owner) || '.' || UPPER(p_table_name) || ' A';
            END IF;

            --Verificando a existência da clausula WHERE
            IF p_where_clause IS NOT NULL THEN
                v_SQL := v_SQL || ' ' || p_where_clause;
            END IF;
            dbms_output.put_line('*********************************************************************' );--NULL;
            dbms_output.put_line('* CTAS BACKUP EXECUTED SUCCESSFULLY' );--NULL;
            dbms_output.put_line('* PHYSICAL TABLE NAME: ' || v_physical_table_name);
            dbms_output.put_line('*********************************************************************' );--NULL;
            dbms_output.put_line(substr('SQL = '||v_SQL,1,255));
            --Gravando na tabela de lista


            INSERT INTO ctas_change_backup.ctas_cb_list
            VALUES (v_list_id, p_change_number, v_version_id, UPPER(p_owner), UPPER(p_table_name), SYSDATE,
                    p_exp_date, sys.dbms_metadata.get_ddl('TABLE', UPPER(p_table_name), UPPER(p_owner)) , ----Capturando metadata da tabela
                    SYS_CONTEXT('USERENV', 'OS_USER'),  NVL(SYS_CONTEXT('USERENV','IP_ADDRESS'),'-'), SYS_CONTEXT('USERENV','HOST'),
                    p_where_clause, p_partition_name,  p_is_unrecoverable, 'N', SYSDATE, SYS_CONTEXT('USERENV', 'OS_USER'), v_physical_table_name);

            EXECUTE IMMEDIATE v_SQL;

            COMMIT;
    END;

    --NULL;
  END;



  PROCEDURE drop_backup
  ( p_change_number  IN ctas_change_backup.ctas_cb_list.cb_change_number%TYPE,
    p_version_id     IN ctas_change_backup.ctas_cb_list.cb_version_id%TYPE
  ) IS

  err_tableSpaceNOTexists   EXCEPTION;
  v_cb_id_list              ctas_change_backup.ctas_cb_oper_log.cb_list_id%TYPE;
  v_log_id                  NUMBER(10,0);
  v_physical_table_name     ctas_change_backup.ctas_cb_list.cb_physc_table%TYPE;
  v_sqlerrmsg               VARCHAR(2000);
  v_sqlcode                 VARCHAR(20);

  BEGIN

    --Atualizando a tabela backup list
    UPDATE ctas_change_backup.ctas_cb_list a
    SET a.CB_DEL_FLAG       = 'Y', --Deletando o registro logicamente
        a.CB_UPDATE_DT      = SYSDATE,
        a.CB_UPDATE_USR     = SYS_CONTEXT('USERENV', 'OS_USER')
    WHERE a.cb_change_number    = p_change_number
      AND a.cb_version_id       = p_version_id
      AND a.cb_del_flag         = 'N'
    RETURNING a.cb_list_id, cb_physc_table
    INTO v_cb_id_list, v_physical_table_name;

    IF SQL%ROWCOUNT <= 0 THEN
        RAISE err_tableSpaceNOTexists;
    END IF;

    SELECT ctas_change_backup.seq_log_id.NEXTVAL INTO v_log_id FROM dual;

    INSERT INTO ctas_change_backup.ctas_cb_oper_log
    VALUES(v_cb_id_list, v_log_id , 'N', cons_log_msg_DROP_COMMAND,
           NULL, NULL, 'Dropping Backup', SYSDATE, sys_context('USERENV', 'OS_USER'),
           NVL(SYS_CONTEXT('USERENV','IP_ADDRESS'),'0.0.0.0'), sys_context('USERENV','HOST'));

    COMMIT;

    EXECUTE IMMEDIATE 'DROP TABLE ' || cons_BACKUPUSER || '.' || v_physical_table_name;

  EXCEPTION
    WHEN err_tableSpaceNOTexists THEN
        dbms_output.put_line('*********************************************************************' );--NULL;
        dbms_output.put_line('* PACKAGE ERROR!' );--NULL;
        dbms_output.put_line('* ERR: Backup doesn''t exist.' );--NULL;
        dbms_output.put_line('* Check the change number and its version. ');
        dbms_output.put_line('* Check the list_available method. ');
        dbms_output.put_line('*********************************************************************' );--NULL;
        ROLLBACK;
        RAISE;
    WHEN OTHERS THEN
        v_sqlerrmsg := SUBSTR(SQLERRM,1,2000);
        v_sqlcode   := SQLCODE;
        INSERT INTO ctas_change_backup.ctas_cb_oper_log
        VALUES(v_cb_id_list, v_log_id , 'Y', v_sqlerrmsg,
               v_sqlcode, NULL, 'Dropping Backup', SYSDATE, sys_context('USERENV', 'OS_USER'),
               NVL(SYS_CONTEXT('USERENV','IP_ADDRESS'),'0.0.0.0'), sys_context('USERENV','HOST'));
        COMMIT;
        RAISE;
  END;

  FUNCTION show_metadata   ( p_change_number  IN ctas_change_backup.ctas_cb_list.cb_change_number%TYPE,
                             p_version_id     IN ctas_change_backup.ctas_cb_list.cb_version_id%TYPE
                           )
  RETURN SYS_REFCURSOR
  IS
    refcur_BKPLIST  SYS_REFCURSOR;
  BEGIN
        OPEN refcur_BKPLIST FOR
        SELECT cb_table_metadata table_metadata
        FROM ctas_change_backup.ctas_cb_list
        WHERE cb_change_number = p_change_number
          AND cb_version_id = p_version_id
          AND cb_del_flag = 'N';

        RETURN refcur_BKPLIST;
  END;

  FUNCTION list_expired
  RETURN SYS_REFCURSOR
  IS
    refcur_BKPLIST  SYS_REFCURSOR;
  BEGIN
        OPEN refcur_BKPLIST FOR
        SELECT cb_change_number change_number, cb_version_id version_id,
               cb_table_owner table_owner, cb_table_name table_name,
               TO_CHAR(cd_backup_date,'DD/MM/YYYY HH:MI:SS') backup_date,
               TO_CHAR(cb_exp_date,'DD/MM/YYYY HH:MI:SS') exp_date
        FROM ctas_change_backup.ctas_cb_list
        WHERE cb_exp_date < sysdate
          AND cb_del_flag = 'N';

        RETURN refcur_BKPLIST;
  END;

  FUNCTION list_available
  RETURN SYS_REFCURSOR
  IS
    refcur_BKPLIST  SYS_REFCURSOR;
  BEGIN
        OPEN refcur_BKPLIST FOR
        SELECT CASE WHEN a.cb_exp_date < SYSDATE THEN '*EXPIRED*' ELSE 'AVAILABLE' END STATUS,
               cb_change_number change_number, cb_version_id version_id,
               cb_table_owner table_owner, cb_table_name table_name,
               TO_CHAR(cd_backup_date,'DD/MM/YYYY HH:MI:SS') backup_date,
               TO_CHAR(cb_exp_date,'DD/MM/YYYY HH:MI:SS') exp_date,
               ( SELECT sum(b.bytes)/1024/1024 MB
                   FROM sys.dba_segments b
                  WHERE a.cb_table_owner  = b.owner
                    AND a.cb_table_name   = b.segment_name
               GROUP BY b.owner, b.segment_name ) MB
        FROM ctas_change_backup.ctas_cb_list a
        WHERE a.CB_DEL_FLAG = 'N';

        RETURN refcur_BKPLIST;
  END;

  PROCEDURE help IS BEGIN NULL; END;

END;
/


-- End of DDL Script for Package Body CTAS_CHANGE_BACKUP.PKG_CTAS_BACKUP
