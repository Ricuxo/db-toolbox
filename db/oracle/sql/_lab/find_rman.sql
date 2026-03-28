set linesize 200
set trimspool on
set heading ON
set underline =
set feedback off
COL COMANDO FORMAT A50
col sid format 9999
COL PCT FORMAT A7
COL PID_NO_SO FORMAT A8

prompt '=============================================================================='
prompt ' A query abaixo mostra os processos de RMAN ainda no Database e sugere'
prompt ' o comando de kill - execute somente o processo se tiver certeza que  '
prompt ' esse processo deve ser morto'
prompt '=============================================================================='
prompt ' Se o retorno for zero rows, pode ser que o shell rman.sh ainda esteja ativo'
prompt ' somente no sistema operacional - digite o comando: ps -ef | grep rman '
prompt ' diretamente no servidor que abriram o chamado para confirmar se ha algum  '
prompt ' processo rman.sh antigo com o status de congelamento que precise ser morto   '
prompt '=============================================================================='

select SD,SERIAL,PID_NO_SO, INICIO,STATUS,PCT,COMANDO FROM
(SELECT b.sid SD,
       b.serial# serial,
       p.spid PID_NO_SO,
       TO_CHAR(a.START_TIME,'dd/mm/yyyy HH24:MI:SS') INICIO,
       decode(ROUND((a.SOFAR/decode(a.TOTALWORK,0,1,a.TOTALWORK))*100,2), 100, 'FINALIZADO', 'EXECUTANDO') status,
       ROUND((a.SOFAR/decode(a.TOTALWORK,0,1,a.TOTALWORK))*100,2)||'%' PCT,
       'alter system kill session '||chr(39)||b.sid||','||b.serial#||chr(39)||';' COMANDO
 FROM gv$session_longops a, gv$session b, gv$process p
 where a.totalwork > 0 and
       a.inst_id = b.inst_id and
       a.sid = b.sid and
       a.OPNAME = 'RMAN: aggregate input' and
       p.addr = b.paddr and
       (a.SOFAR/decode(a.TOTALWORK,0,1,a.TOTALWORK))*100 <= 100)



/