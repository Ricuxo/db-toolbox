Rem
Rem    NOME
Rem      tophash.sql  
Rem
Rem    DESCRIÇÃO
Rem      Lista a quantidade de um determinado hash_value das sessões ativas no banco      
Rem
Rem    UTILIZAÇÃO
Rem      @tophash
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem      FERR@RI      07/08/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

SELECT inst_id, a.sql_hash_value, module,
       count(*) as TOTAL
FROM   gv$session a
WHERE  a.status = 'ACTIVE'
and    type <> 'BACKGROUND'
group by inst_id, module,a.sql_hash_value
ORDER BY 4,3
/

