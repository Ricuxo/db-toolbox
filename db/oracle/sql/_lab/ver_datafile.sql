REM " Visualiza datafiles de um tablespace"
REM " Autor - Luiz Noronha - 02/09/2011"

SET verify 		OFF;
SET lin 		1000;
SET FEED 		OFF;

COLUMN NAME FOR A100
COMPUTE SUM OF MB ON REPORT
BREAK ON REPORT

SELECT rownum count_index, d.file#, d.name, d.status, d.bytes/1024/1024 mb, d.block_size
  FROM v$datafile d INNER JOIN v$tablespace t
    ON (d.TS# = t.TS#)
 WHERE UPPER(t.name) = UPPER('&1');

@clear
