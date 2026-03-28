Rem
Rem    NOME
Rem      tbsincrease.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista nome, tamanho e data de criação de todos 
Rem      os datafiles de um tablespace específico.
Rem
Rem    UTILIZAÇÃO
Rem      @tbsincrease <NOME_DA_TABLESPACE>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      27/12/06 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

--
set verify off
col TABLESPACE format A30
col DATAFILE   format A60
--
Select d.TABLESPACE_NAME as TABLESPACE, 
       d.FILE_NAME AS DATAFILE, 
       d.BYTES/1024 as KBYTES, 
       to_char(v.CREATION_TIME, 'dd-mon-yyyy hh24:mm:ss') as "DATA CRIAÇÃO"
from dba_data_files d, v$datafile v
where d.file_id = v.file# 
and d.TABLESPACE_NAME = upper ('&1')
order by v.CREATION_TIME
/

set verify on