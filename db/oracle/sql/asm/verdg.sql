--Mostra diskgroups com tamanho total , livre e porcentagem de utilização
--Ele mostra todos ou por diskgroup

accept v_diskgroup CHAR prompt 'Diskgroup, já contém % %, [ENTER] = todas:'

SELECT NAME, TOTAL_MB,FREE_MB, ROUND((1- (FREE_MB / TOTAL_MB))*100, 2) AS "PORCENTAGEM" 
FROM V$ASM_DISKGROUP
WHERE NAME like upper('%&v_diskgroup%')
ORDER BY 3;