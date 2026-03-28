Rem
Rem    NOME
Rem      version.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script mostra a release do servidor Oracle e seus componentes.
Rem
Rem    UTILIZAÇÃO
Rem      @version
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      30/01/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

select * 
from v$version
/


