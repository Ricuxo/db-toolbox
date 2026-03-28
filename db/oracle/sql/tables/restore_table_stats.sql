/*Restaura estatisticas baseado por data.

Exemplo de saida:

SQL> @tab_stats_history
Enter value for owner: SCOTT
Enter value for table_name: EMP

OWNER                          TABLE_NAME                STATS_UPDATE_TIME
------------------------------ ------------------------- -------------------------------------
SCOTT                          EMP                       01-APR-17 01.28.05.300409 PM -03:00
SCOTT                          EMP                       12-APR-17 03.21.23.751332 PM -03:00

SQL> @restore_table_stats
Enter value for owner: SCOTT
Enter value for table_name: EMP
Enter value for as_of_date: 02-apr-17

PL/SQL procedure successfully completed.


SQL> @dba_tables
Enter value for owner: SCOTT
Enter value for table_name: EMP

OWNER                          TABLE_NAME                STATUS   LAST_ANAL   NUM_ROWS     BLOCKS
------------------------------ ------------------------- -------- --------- ---------- ----------
SCOTT                          EMP                       VALID    01-APR-17         14          5

*/

begin
   dbms_stats.restore_table_stats (
      '&Owner',
      '&table_name',
      '&as_of_date'||' 12.00.00.000000000 AM -04:00'); /* Noon */
end;
/
