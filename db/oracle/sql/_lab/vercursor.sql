Rem
Rem    NOME
Rem      vercursor.sql 
Rem
Rem    DESCRIÇÃO
Rem      Este script verifica os cursores abertos e conta por sessão.
Rem
Rem    UTILIZAÇÃO
Rem      @vercursor
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      02/04/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

SELECT sid, 
       count(*)
FROM v$open_cursor
GROUP BY sid
ORDER BY count(*)
/
