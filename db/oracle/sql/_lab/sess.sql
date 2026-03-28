set lines 1000
column inst_id form 999
columN sid FORM 9999999
columN serial FORM 999999
columN maquina FORM A19
columN programa FORM A30
columN TERMINAL FORM A10
columN logon_time FORM A19
columN DT_HR_ATUAL FORM A19
columN OSUSER FORM A25
columN USUARIO FORM A20
columN MODULO FORM A40
Select vs.INST_ID INST_ID,
       vs.SID SID,
       vs.Serial# Serial,
       vp.spid,
       vs.USERNAME USUARIO,
       vs.STATUS STATUS,
       vs.MACHINE MAQUINA,
       vs.PROGRAM PROGRAMA,
       SUBSTR(to_char(vs.LOGON_TIME, 'DD-MM-YY HH24:MI:SS'),1,17) LOGON_TIME,
       vs.terminal,
       vs.osuser,
       vs.TYPE TIPO,
       SUBSTR(to_char(sysdate, 'DD-MM-YY HH24:MI:SS'),1,17) DT_HR_ATUAL,
       vs.MODULE MODULO
  from Gv$process vp, Gv$session vs
 where vs.paddr = vp.addr
 AND   vs.USERNAME like upper('%&username%') 
 AND   upper(vs.OSUSER) LIKE upper('%&osuser%')
/
