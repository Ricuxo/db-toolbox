Rem
Rem    NOME
Rem      ovo.sql
Rem
Rem    DESCRIÇÃO
Rem      Este script monta as entradas para configuração de 
Rem      monitoraçao de tablespaces no HP OVO.
Rem      
Rem    UTILIZAÇÃO
Rem      @ovo
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       08/10/08 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------

SELECT TABLESPACE_NAME||' LIM'||' '||  
case
    when GIGAS < 101  then '15'
    when GIGAS < 501  then '10'
    else '05'
end, 
GIGAS
FROM (SELECT D.TABLESPACE_NAME, round(SUM(D.BYTES)/1024/1024/1024,0) GIGAS
      FROM DBA_DATA_FILES D ,DBA_TABLESPACES T
      WHERE D.TABLESPACE_NAME = T.TABLESPACE_NAME
      AND T.CONTENTS NOT IN ('UNDO','TEMPORARY')
      GROUP BY D.TABLESPACE_NAME)
ORDER BY 1
/
