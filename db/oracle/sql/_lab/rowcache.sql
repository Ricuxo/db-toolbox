Rem
Rem    NOME
Rem      rowcache.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script fornece informações sobre o cache de dicionario(row_cache). 
Rem      
Rem    UTILIZAÇÃO
Rem      @rowcache
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       04/05/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

set feedback off

PROMPT
PROMPT Verificar se GETMISSES_PCT é menor que 15% para todo o cache de dicionario.

select sum(GETS) as total_gets, 
       sum(GETMISSES) as total_misses, 
       round(((sum(GETMISSES)/sum(GETS))*100),2) AS getsmisses_pct
from v$rowcache
order by getsmisses_pct desc
/


PROMPT
PROMPT
PROMPT Verificar se GETMISSES_PCT é menor que 2% para a maioria dos objetos.

select PARAMETER, GETS, GETMISSES, round(((GETMISSES/GETS)*100),2) AS getsmisses_pct
from v$rowcache
where getmisses > 0
order by getsmisses_pct desc
/

set feedback on

