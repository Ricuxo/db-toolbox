mber 23, 2008, by Fáo Telles Rodriguez - No comments yet
Viewed 2442 times
 Go back to SAVEPOINT

Bom, todo DBA que se prese deve acompanhar o crescimento da base conforme o tempo. Prever o espaçem disco necessáo nos próos meses, saber qual éca ocorre maior crescimento da base. Acompanhar de perto objetos crícos que ocupam mais espeç etc. Éclaro que a próa Oracle e outros fornecedores possuem ferramentas bastente sofisticadas para fazer algumas destas coisas. Ébem verdade que boa parte delas faz em maior ou menor grau algo bem semelhante ao que vou mostrar adiante. No entanto, eu gosto da minha soluç, pois eu consigo entendêa facilmente e modificar para necessidades especícas. No mímo ém bom exercío de aprendizado.

Vejamos alguns requisitos que eu montei:

Ser compatíl com pelo menos o Oracle 8 em diante;
Armazenar todas informaçs num tablespace separado, para que a coleta de dados nãinfluencie nos demais tablespaces;
Utilizar um esquema separado para a criaç de todos os objetos envolvidos. O usuáo em questãdeveráer bloqueado e ter o mímo de priviléos necessáos;
Criar uma tabela para registrar a data de duraç no disparo de cada script e outra para os erros que por ventura venham a ocorrer;
Coletar as seguintes informaçs com as respectivas periodicidades:
Dados sobre o tamanho dos tablespaces uma vez por mê
Dados sobre a quantidade e tipo de objetos por esquema uma vez por dia, atualizando apenas as mudanç ocorridas;
Nome dos objetos invádos auma vez por dia, atualizando apenas as mudanç ocorridas;
Tamanhode objetos que ocupem mais de 64MB ou tenham mais de 50 extents ou mais de um milhãde registros uma vez por semana, atualizando apenas as mudanç ocorridas;
Objetos
*/


CREATE TABLESPACE DBA_LOG_DADOS
  DATAFILE '/u02/oradata/T1DATBR3/DATA/dba_log_dados_01.dbf'
  SIZE 100M LOGGING EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO;
 
CREATE USER dba_log IDENTIFIED BY dba
    DEFAULT TABLESPACE dba_log_dados
    QUOTA UNLIMITED ON dba_log_dados
    ACCOUNT LOCK;
 
GRANT CREATE PROCEDURE TO dba_log;
GRANT CREATE TABLE TO dba_log;
 
-- Executar como SYSDBA
GRANT SELECT ON dba_objects TO dba_log;
GRANT SELECT ON dba_segments TO dba_log;
GRANT SELECT ON dba_data_files TO dba_log;
GRANT SELECT ON dba_free_space TO dba_log;
GRANT SELECT ON dba_tables TO dba_log;
 
CREATE SEQUENCE dba_log.log_seq;
 
CREATE TABLE dba_log.log(
    id_log      number(10),
    rotina      varchar2(100),
    usuario     varchar2(30) DEFAULT USER,
    inicio      date DEFAULT SYSDATE,
    fim         date,
    CONSTRAINT  log_pk PRIMARY KEY(id_log)
);
 
CREATE TABLE dba_log.erros (
    id_log      number(10),
    cod_erro    number(10),
    mensagem     varchar2(64),
    DATA        TIMESTAMP DEFAULT SYSTIMESTAMP
);
 
CREATE TABLE dba_log.tablespace (
    nome        varchar2(30),
    maximo      number(8) NOT NULL,
    alocado     number(8) NOT NULL,
    utilizado   number(8) NOT NULL,
    livre       number(8) NOT NULL,
    DATA        date DEFAULT SYSDATE,
    CONSTRAINT tablespaces_pk PRIMARY KEY (nome,DATA)
);
 
CREATE OR REPLACE PROCEDURE dba_log.tablespace_load AS
  v_log_seq number(10);
  v_code number(10);
  v_errm varchar2(64);
BEGIN
 
  SELECT dba_log.log_seq.NEXTVAL INTO v_log_seq FROM dual;
  INSERT INTO dba_log.log (id_log, rotina) VALUES (v_log_seq,'tablespace_load');
 
  INSERT INTO dba_log.tablespace (nome, maximo, alocado, utilizado, livre)
    SELECT
      u.tablespace_name,
      m.maximo,
      m.alocado,
      u.utilizado,
      l.livre
      FROM
        (SELECT tablespace_name, CEIL (SUM (bytes) / 1048576) utilizado
           FROM dba_segments
           GROUP BY tablespace_name) u,
        (SELECT
           tablespace_name,
           CEIL (SUM (bytes) / 1048576) alocado,
           CEIL (SUM (DECODE (autoextensible, 'NO', bytes, maxbytes)) / 1048576) maximo
           FROM dba_data_files
           GROUP BY tablespace_name) m,
        (SELECT
           tablespace_name,
           CEIL (SUM (bytes) / 1048576) livre
           FROM dba_free_space
           GROUP BY tablespace_name) l
      WHERE
        l.tablespace_name = u.tablespace_name AND
        l.tablespace_name = m.tablespace_name
    ;
  UPDATE dba_log.log SET fim = SYSDATE WHERE id_log = v_log_seq;
  COMMIT;
 
  EXCEPTION
    WHEN OTHERS THEN
      v_code := SQLCODE;
      v_errm := SUBSTR(SQLERRM, 1 , 64);
      INSERT INTO dba_log.erros (id_log, cod_erro, mensagem) VALUES (v_log_seq, v_code, v_errm);
END;
/
 
CREATE TABLE dba_log.objeto_qt (
    tipo        varchar2(19),
    esquema     varchar2(30),
    STATUS      varchar2(7),
    qt          number(5) NOT NULL,
    DATA        date DEFAULT SYSDATE,
    CONSTRAINT objeto_qt_pk PRIMARY KEY (tipo, esquema, STATUS, DATA)
);
 
CREATE OR REPLACE PROCEDURE dba_log.objeto_qt_load AS
  v_log_seq number(10);
  v_code number(10);
  v_errm varchar2(64);
BEGIN
  SELECT dba_log.log_seq.NEXTVAL INTO v_log_seq FROM dual;
  INSERT INTO dba_log.log (id_log, rotina) VALUES (v_log_seq,'objeto_qt_load');
 
  INSERT INTO dba_log.objeto_qt (tipo, esquema, STATUS, qt)
    SELECT b.tipo, b.esquema, b.STATUS, b.qt
      FROM
        (SELECT object_type tipo, owner esquema, STATUS FROM dba_objects
           MINUS
           SELECT tipo, esquema, STATUS FROM dba_log.objeto_qt) a,
        (SELECT object_type tipo, owner esquema, STATUS, count(*) qt
           FROM dba_objects
           GROUP BY owner, object_type, STATUS) b
      WHERE
        a.tipo = b.tipo AND
        a.esquema = b.esquema AND
        a.STATUS = b.STATUS
      ORDER BY esquema, tipo, STATUS
   ;
 
  INSERT INTO dba_log.objeto_qt (tipo, esquema, STATUS, qt)
    SELECT o.tipo, o.esquema, o.STATUS, o.qt
      FROM
        dba_log.objeto_qt q,
        (SELECT object_type tipo, owner esquema, STATUS, count(*) qt
           FROM dba_objects
           GROUP BY owner, object_type, STATUS) o,
        (SELECT tipo, esquema, STATUS, max(DATA) DATA
           FROM dba_log.objeto_qt
           GROUP BY tipo, esquema, STATUS) d
      WHERE
        o.tipo = q.tipo AND
        o.tipo = d.tipo AND
        o.esquema = q.esquema AND
        o.esquema = d.esquema AND
        o.STATUS = q.STATUS AND
        o.STATUS = d.STATUS AND
        q.DATA = d.DATA AND
        o.qt != q.qt
        ORDER BY o.esquema, o.tipo, o.STATUS
  ;
  UPDATE dba_log.log SET fim = SYSDATE WHERE id_log = v_log_seq;
  COMMIT;
 
  EXCEPTION
    WHEN OTHERS THEN
      v_code := SQLCODE;
      v_errm := SUBSTR(SQLERRM, 1 , 64);
      INSERT INTO erros (id_log, cod_erro, mensagem) VALUES (v_log_seq, v_code, v_errm);
END;
/
 
CREATE TABLE dba_log.objeto_invalido (
    tipo        varchar2(19),
    esquema     varchar2(30),
    nome        varchar2(128),
    DATA        date DEFAULT SYSDATE,
    CONSTRAINT objeto_invalido_pk PRIMARY KEY (tipo, esquema, nome, DATA)
);
 
CREATE OR REPLACE PROCEDURE dba_log.objeto_invalido_load AS
  v_log_seq number(10);
  v_code number(10);
  v_errm varchar2(64);
 
BEGIN
  SELECT dba_log.log_seq.NEXTVAL INTO v_log_seq FROM dual;
  INSERT INTO dba_log.log (id_log, rotina) VALUES (v_log_seq,'objeto_invalido_load');
  INSERT INTO dba_log.objeto_invalido (tipo, esquema, nome)
    SELECT object_type tipo, owner esquema, object_name nome
      FROM dba_objects
      WHERE STATUS != 'VALID'
    MINUS
    SELECT tipo, esquema, nome FROM dba_log.objeto_invalido
  ;
  UPDATE dba_log.log SET fim = SYSDATE WHERE id_log = v_log_seq;
  COMMIT;
 
  EXCEPTION
    WHEN OTHERS THEN
      v_code := SQLCODE;
      v_errm := SUBSTR(SQLERRM, 1 , 64);
      INSERT INTO dba_log.erros (id_log, cod_erro, mensagem) VALUES (v_log_seq, v_code, v_errm);
END;
/
 
CREATE TABLE dba_log.objeto_tamanho (
    tipo        varchar2(19),
    tablespace  varchar2(30),
    esquema     varchar2(30),
    nome_part   varchar2(112),
    tamanho     number(8),
    extents     number(5),
    num_reg     number(10),
    DATA        date DEFAULT SYSDATE,
    CONSTRAINT objetos_tamanho_pk PRIMARY KEY (tipo, esquema, nome_part, DATA)
);
 
CREATE OR REPLACE PROCEDURE dba_log.objeto_tamanho_load AS
  v_log_seq number(10);
  v_code number(10);
  v_errm varchar2(64);
 
BEGIN
 
  SELECT dba_log.log_seq.NEXTVAL INTO v_log_seq FROM dual;
  INSERT INTO dba_log.log (id_log, rotina) VALUES (v_log_seq,'objeto_tamanho_load');
 
  INSERT INTO dba_log.objeto_tamanho 
    (tipo, tablespace, esquema, nome_part, tamanho, extents, num_reg)
    SELECT b.tipo, b.tablespace, b.esquema, b.nome_part, b.tamanho, b.extents, b.num_reg
    FROM
      (SELECT
         segment_type tipo,
         owner esquema,
         NVL2(partition_name, segment_name || '/' || partition_name, segment_name) nome_part
         FROM dba_segments
      MINUS
      SELECT tipo, esquema, nome_part FROM dba_log.objeto_tamanho) a,
      (SELECT
        s.segment_type tipo,
        s.tablespace_name tablespace,
        s.owner esquema,
        NVL2(s.partition_name, s.segment_name || '/' || s.partition_name, s.segment_name) nome_part,
        CEIL(s.bytes/1048576) tamanho,
        s.extents,
        t.num_rows num_reg
        FROM
          dba_segments s,
          dba_tables t
       WHERE
         (s.bytes > 67108864 OR s.extents > 50 OR t.num_rows > 1000000) AND
          s.owner = t.owner (+)AND
          s.segment_name = t.table_name (+)) b
    WHERE
      a.tipo = b.tipo AND
      a.esquema = b.esquema AND
      a.nome_part = b.nome_part
  ;    
 
  INSERT INTO dba_log.objeto_tamanho 
    (tipo, tablespace, esquema, nome_part, tamanho, extents, num_reg)
    SELECT o.tipo, o.tablespace, o.esquema, o.nome_part, o.tamanho, o.extents, o.num_reg
      FROM
        dba_log.objeto_tamanho l,
        (SELECT tipo, esquema, nome_part, max(DATA) DATA
          FROM dba_log.objeto_tamanho
          GROUP BY tipo, esquema, nome_part) d,
        (SELECT
          s.segment_type tipo,
          s.tablespace_name tablespace,
          s.owner esquema,
          NVL2(s.partition_name, s.segment_name || '/' || s.partition_name, s.segment_name) nome_part,
          CEIL(s.bytes/1048576) tamanho,
          s.extents,
          t.num_rows num_reg
          FROM
            dba_segments s,
            dba_tables t
          WHERE
            (s.bytes > 67108864 OR s.extents > 50 OR t.num_rows > 1000000) AND
            s.owner = t.owner (+)AND
            s.segment_name = t.table_name (+)) o
      WHERE
        l.tipo = d.tipo AND
        l.tipo = o.tipo AND
        l.esquema = d.esquema AND
        l.esquema = o.esquema AND
        l.nome_part = d.nome_part AND
        l.nome_part = o.nome_part AND
        l.DATA = d.DATA AND
        (o.tamanho != CEIL(l.tamanho) OR l.extents != o.extents OR l.num_reg != o.num_reg)
      ORDER BY o.esquema, o.tablespace, o.tipo DESC
  ;
  UPDATE dba_log.log SET fim = SYSDATE WHERE id_log = v_log_seq;
  COMMIT;
 
  EXCEPTION
    WHEN OTHERS THEN
      v_code := SQLCODE;
      v_errm := SUBSTR(SQLERRM, 1 , 64);
      INSERT INTO dba_log.erros (id_log, cod_erro, mensagem) VALUES (v_log_seq, v_code, v_errm);
END;
/


/*Agendamento

Se vocêstiver utilizando o Oracle 10g ou superior, deve preferir usar o SCHEDULER:
*/

BEGIN
 
  DBMS_SCHEDULER.CREATE_WINDOW(
    window_name=>'SYS.MONTH_START_WINDOW',
    resource_plan=>'SYSTEM_PLAN',
    start_date=>SYSTIMESTAMP,
    duration=>numtodsinterval(240, 'minute'),
    repeat_interval=>'FREQ=MONTHLY;BYMONTHDAY=1;BYHOUR=3',
    end_date=>null,
    window_priority=>'LOW',
    comments=>'Start of the month window for maintenance task'
  );
 
  DBMS_SCHEDULER.CREATE_JOB(
    job_name => 'DBA_LOG.TABLESPACE_LOAD_MENSAL',
    job_type => 'STORED_PROCEDURE',
    job_action => 'DBA_LOG.TABLESPACE_LOAD',
    schedule_name => 'SYS.MONTH_START_WINDOW',
    enabled => TRUE
  );
 
  DBMS_SCHEDULER.SET_ATTRIBUTE(
    name => '"DBA_LOG"."TABLESPACE_LOAD_MENSAL"',
    attribute => 'job_priority',
    value => 4
  );
 
  DBMS_SCHEDULER.CREATE_JOB(
    job_name => 'DBA_LOG.OBJETO_TAMANHO_LOAD_SEMANAL',
    job_type => 'STORED_PROCEDURE',
    job_action => 'DBA_LOG.OBJETO_TAMANHO_LOAD',
    schedule_name => 'SYS.WEEKEND_WINDOW',
    enabled => TRUE
  );
 
  DBMS_SCHEDULER.SET_ATTRIBUTE(
    name => 'DBA_LOG.OBJETO_TAMANHO_LOAD_SEMANAL',
    attribute => 'job_priority',
    value => 4
  );
 
  DBMS_SCHEDULER.CREATE_JOB(
    job_name => 'DBA_LOG.OBJETO_INVALIDO_LOAD_DIARIO',
    job_type => 'STORED_PROCEDURE',
    job_action => 'DBA_LOG.OBJETO_INVALIDO_LOAD',
    schedule_name => 'SYS.WEEKNIGHT_WINDOW',
    enabled => TRUE
  );
 
  DBMS_SCHEDULER.SET_ATTRIBUTE(
    name => 'DBA_LOG.OBJETO_INVALIDO_LOAD_DIARIO',
    attribute => 'job_priority',
    value => 4
  );
 
  DBMS_SCHEDULER.CREATE_JOB(
    job_name => 'DBA_LOG.OBJETO_QT_LOAD_DIARIO',
    job_type => 'STORED_PROCEDURE',
    job_action => 'DBA_LOG.OBJETO_QT_LOAD',
    schedule_name => 'SYS.WEEKNIGHT_WINDOW',
    enabled => TRUE
  );
 
  DBMS_SCHEDULER.SET_ATTRIBUTE(
    name => 'DBA_LOG.OBJETO_QT_LOAD_DIARIO',
    attribute => 'job_priority',
    value => 4
  );
 
END;
/


/*
Conclusã
Com os dados coletados nas tabelas, vocêóecisa agora exercitar um pouco do seu conhecimento de SQL para fazer consultas
 criativas e gerar relatós dos mais diversos e entregar para o seu chefe no final do ano. Nã adianta nada criar os objetos 
 agora e tentar fazer máca. Apóm anos, vocêoderábservar com alguma precisãa sazonalidade das aplicaçs e fazer boas projeçs. 
 Que tal começ o ano com um mímo de coleta de dados na sua base? Quando a turma do ITIL bater na sua porta, algumas coisas jástarã
 encaminhadas para o seu lado.
 */


