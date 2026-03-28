/*  */

REM*********************************************************
REM PROD_PROF.SQL
REM
REM SCRIPT RESTRICTS A USERS ABILITY TO USE SQL FOR ANYTHING
REM OTHER THAN SELECT. RESTRICTS 
REM DELETE,INSERT,
REM INSERT INTO, AND HOST COMMANDS.
REM
REM USE: SQLPLUS SYSTEM/PW @PRODUCT USER_PRODUCT_PROFILE USERNAME
REM
REM    DATE        CHANGE            REASON        NAME
REM    -------     ---------------   -----------   ------------
REM    8/6/92      INITIAL CREATE    N/A           M. AULT
REM    1/11/97     Updated to V7     V6 not used   M.Ault
REM******************************************************************
SET VERIFY OFF

INSERT INTO PRODUCT_PROFILE (
product,
userid,
attribute,
char_value,
date_value)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'DELETE','DISABLED',SYSDATE);

INSERT INTO PRODUCT_PROFILE (
product,
userid,
attribute,
char_value,
date_value)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'INSERT','DISABLED',SYSDATE);

INSERT INTO PRODUCT_PROFILE (
product,
userid,
attribute,
char_value,
date_value)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'UPDATE','DISABLED',SYSDATE);

INSERT INTO PRODUCT_PROFILE (
product,
userid,
attribute,
char_value,
date_value)
VALUES ('SQL*Plus',UPPER('&&USERNAME'),'HOST','DISABLED',SYSDATE);

COMMIT;

