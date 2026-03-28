Rem
Rem    NOME
Rem      undousage.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script descreve a quantidade de blocos de UNDO em cada status.
Rem      
Rem    UTILIZAÇÃO
Rem      @undousage
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      19/08/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------


SELECT DISTINCT STATUS, 
       SUM(BYTES)/1024/1024 as TAM_MB, 
       sum(blocks) 
FROM DBA_UNDO_EXTENTS 
GROUP BY STATUS
/


alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'; 
select usn, 
       state, 
       undoblockstotal "Total", 
       undoblocksdone "Done", 
       undoblockstotal-undoblocksdone "ToDo", 
       round((undoblocksdone/undoblockstotal) * 100,2) Percentual,
       decode(cputime,0,'unknown',sysdate+(((undoblockstotal-undoblocksdone) / (undoblocksdone / cputime)) / 86400)) "Estimated time to complete"
from v$fast_start_transactions
/ 


select ktuxeusn, to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') "Time", ktuxesiz, ktuxesta
from x$ktuxe
where ktuxecfl = 'DEAD'
and ktuxesiz > 0
/
