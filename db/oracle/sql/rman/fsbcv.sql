Rem
Rem    NOME
Rem      fsbcv.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script lista o nome dos filesystems que contém arquivos    
Rem      do banco de dados, como: datafiles de dados, indices, undo, 
Rem      redo e o filesystem do binário do Oracle.    
Rem   
Rem    UTILIZAÇÃO
Rem      fsbcv.sql
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      23/11/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------


col "Filesystem: Binário" for a30
col "Filesystems: Dados, Ind e Undo" for a30
col "Filesystem: Redo" for a30
set feedback off

select distinct(substr(VALUE,1,instr(VALUE,'/',2)-1)) as "Filesystem: Binário"
from v$parameter
where name = 'background_dump_dest'
/

select distinct(substr(file_name,1,instr(file_name,'/',2)-1)) as "Filesystems: Dados, Ind e Undo"
from dba_data_files
order by 1
/

select distinct(substr(MEMBER,1,instr(MEMBER,'/',2)-1)) as "Filesystem: Redo"
from V$LOGFILE
order by 1
/



-- outro exemplo
-- select substr(file_name,1,instr(ltrim(file_name,'/'),'/')) from dba_data_files