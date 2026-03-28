Rem
Rem    NOME
Rem      arch.sql  
Rem
Rem    DESCRIÇÃO
Rem      Este script cria uma matriz com a quantidade de archives gerados por dia e hora.
Rem      
Rem    UTILIZAÇÃO
Rem      @arch
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem     FERR@RI       26/01/07 - criação do script
Rem
Rem ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------

PROMPT
PROMPT    DESCRIÇÃO: Este script cria uma matriz com a quantidade de archives gerados por dia e hora.

col DAY for a3
col TOTAL for a6
col H00 for a4
col H01 for a4
col H02 for a4
col H03 for a4
col H04 for a4
col H05 for a4
col H06 for a4
col H07 for a4
col H08 for a4
col H09 for a4
col H10 for a4
col H11 for a4
col H12 for a4
col H13 for a4
col H14 for a4
col H15 for a4
col H16 for a4
col H17 for a4
col H18 for a4
col H19 for a4
col H20 for a4
col H21 for a4
col H22 for a4
col H23 for a4

SELECT  trunc(first_time) "Date",
        to_char(first_time, 'Dy') "Day",
        substr(count(1),1,5) as "Total",
        substr(SUM(decode(to_char(first_time, 'hh24'),'00',1,0)),1,3) as "h00",
        substr(SUM(decode(to_char(first_time, 'hh24'),'01',1,0)),1,3) as "h01",
        substr(SUM(decode(to_char(first_time, 'hh24'),'02',1,0)),1,3) as "h02",
        substr(SUM(decode(to_char(first_time, 'hh24'),'03',1,0)),1,3) as "h03",
        substr(SUM(decode(to_char(first_time, 'hh24'),'04',1,0)),1,3) as "h04",
        substr(SUM(decode(to_char(first_time, 'hh24'),'05',1,0)),1,3) as "h05",
        substr(SUM(decode(to_char(first_time, 'hh24'),'06',1,0)),1,3) as "h06",
        substr(SUM(decode(to_char(first_time, 'hh24'),'07',1,0)),1,3) as "h07",
        substr(SUM(decode(to_char(first_time, 'hh24'),'08',1,0)),1,3) as "h08",
        substr(SUM(decode(to_char(first_time, 'hh24'),'09',1,0)),1,3) as "h09",
        substr(SUM(decode(to_char(first_time, 'hh24'),'10',1,0)),1,3) as "h10",
        substr(SUM(decode(to_char(first_time, 'hh24'),'11',1,0)),1,3) as "h11",
        substr(SUM(decode(to_char(first_time, 'hh24'),'12',1,0)),1,3) as "h12",
        substr(SUM(decode(to_char(first_time, 'hh24'),'13',1,0)),1,3) as "h13",
        substr(SUM(decode(to_char(first_time, 'hh24'),'14',1,0)),1,3) as "h14",
        substr(SUM(decode(to_char(first_time, 'hh24'),'15',1,0)),1,3) as "h15",
        substr(SUM(decode(to_char(first_time, 'hh24'),'16',1,0)),1,3) as "h16",
        substr(SUM(decode(to_char(first_time, 'hh24'),'17',1,0)),1,3) as "h17",
        substr(SUM(decode(to_char(first_time, 'hh24'),'18',1,0)),1,3) as "h18",
        substr(SUM(decode(to_char(first_time, 'hh24'),'19',1,0)),1,3) as "h19",
        substr(SUM(decode(to_char(first_time, 'hh24'),'20',1,0)),1,3) as "h20",
        substr(SUM(decode(to_char(first_time, 'hh24'),'21',1,0)),1,3) as "h21",
        substr(SUM(decode(to_char(first_time, 'hh24'),'22',1,0)),1,3) as "h22",
        substr(SUM(decode(to_char(first_time, 'hh24'),'23',1,0)),1,3) as "h23"
FROM    V$log_history
group by trunc(first_time), to_char(first_time, 'Dy') 
order by 1
/
