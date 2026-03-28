Rem
Rem    NOME
Rem      dict.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script lista as views do dicionário da dados.
Rem      
Rem    UTILIZAÇÃO
Rem      @dict <view_name>
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       11/05/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------


col table_name for a30
col comments for a80

select TABLE_NAME, 
       COMMENTS
from dict
where TABLE_NAME like upper ('%&1%')
order by 1
/
