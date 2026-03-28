--|#########################################################################
--|# Program: Verificar se a instância está 'OK'
--|# Author:  Gilson Martins (gilson.martins@t-systems.com)
--|# Company: T-Systems do Brasil LTDA.
--|# Version: 1.0
--|#########################################################################

SET LINE  500;
SET PAGES 1000;

COLUMN HOST_NAME	FORMAT 	a40;
COLUMN STARTUP_TIME	FORMAT 	a22;
COLUMN CURRENT_TIME	FORMAT	a22;

SET TIMING OFF;

SELECT 	OPEN_MODE
FROM	gV$DATABASE;

SELECT	INSTANCE_NAME, 
	HOST_NAME, 
	STATUS, 
	TO_CHAR(STARTUP_TIME, 'DD-MM-RRRR HH24:MI:SS') "STARTUP_TIME",
	TO_CHAR(SYSDATE, 'DD-MM-RRRR HH24:MI:SS') "CURRENT_TIME"
FROM	GV$INSTANCE;

PROMPT

--|## THE END ##|--