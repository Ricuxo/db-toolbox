prompt # 
prompt # Verifa sessoes que estao em Lock, 
prompt # PODE ser DEMORADO pois busca a query que está sendo executado.
prompt # 
prompt # Este script retorna informacoes completas das sessoes BLOCKs e WAITs
prompt # inclusive com o comando kill
prompt # 
/*************************************************************************************/
/***********            SCRIPT PARA IDENTIFICAR LOCK                    **************/
/***********							        **************/
/***********  Funcao: Mostrar de forma clara o Blocker e os 	        **************/
/***********	      dependentes "waiter" e o comando que              **************/
/***********	      esta executando      			        **************/
/***********							        **************/
/***********  Obs: Ajuste todos os paths para geracao de spool com nome **************/
/***********  	 de ambiente e data                                     **************/
/***********							        **************/
/*************************************************************************************/

set lines 1000 pages 1000
column retorno format a200
set feedback off
set heading off

SELECT x2.TIPO, x2.SID, 
       (SELECT substr('kill -9 '||P.SPID||'  username='||s.username||
                      '  osuser='||s.osuser||
                      '  hash_value '||A.HASH_VALUE||'  '||A.SQL_TEXT,1,200) 
	  FROM V$PROCESS P, V$SESSION S, V$SQLAREA A 
         WHERE P.ADDR=S.PADDR
	 AND   S.SQL_ADDRESS=A.ADDRESS(+)
	 AND   S.SID=x2.sid
	 and   rownum<2) RETORNO
 from (SELECT x.TIPO, x.SID, x.ID1
         FROM (select decode(block, 1, 'BLOCK', '    WAIT') TIPO, sid, L.ID1
                 from V$LOCK L
                WHERE L.TYPE='TX'
                AND   L.ID1 IN (select L1.ID1 from v$lock L1 
                                 where L1.type='TX' AND L1.BLOCK=1)
               ) x
      ) x2
order by ID1, TIPO DESC;
