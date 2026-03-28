Rem
Rem    NOME
Rem      undotrans.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script descreve a quantidade de blocos de UNDO utilização por uma transação de uma sessão.
Rem      
Rem    UTILIZAÇÃO
Rem      @undotrans
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      03/04/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set feedback off
col username for a20
col osuser for a20

PROMPT 
PROMPT Segmentos de Undo utilizados por sessões (transações ativas)
select b.sid, 
       b.serial#, 
       b.sql_hash_value,
       b.username, 
       b.status,
       a.start_time,         
       a.USED_UBLK as USED_UNDO_BLOCKS, 
       round((a.USED_UBLK*(select VALUE from v$parameter where NAME = 'db_block_size'))/1024/1024,2) USED_UNDO_MB, 
       a.log_io, 
       a.phy_io, 
       b.osuser,
       a.addr        
from v$transaction a, v$session b
where a.addr = b.taddr
order by 8 desc
/

PROMPT
PROMPT 
PROMPT Segmentos de Undo utilizados pela instancia
col status for a20
col tablespace_name for a16
select A.NAME, 
       C.TABLESPACE_NAME, 
       B.STATUS,
       B.EXTENTS,
       B.RSSIZE,
       B.HWMSIZE,
       B.XACTS  
from v$rollname A,  v$rollstat B, dba_rollback_segs c
where A.NAME IN (select SEGMENT_NAME from dba_segments)
  and A.USN = B.USN
  and A.NAME = C.SEGMENT_NAME                                                   
/

PROMPT
PROMPT STATUS : ONLINE ou PENDING OFFLINE - segmento ainda contem sessões ativas
PROMPT EXTENTS: Number of extents in the rollback segment
PROMPT RSSIZE : Size (in bytes) of the rollback segment
PROMPT HWMSIZE: High water mark of rollback segment size
PROMPT XACTS  : Number of active transactions
PROMPT 
 

set feedback on 