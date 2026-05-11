--- Retorno esperado:
--- ACTION_NAME                         TOTAL
--- ------------------------------ ----------
--- SELECT                             222386
--- COMMIT                                192
--- LOGON                                 165
--- ALTER SESSION                         165
--- INSERT                                120
--- LOGOFF                                119
--- ROLLBACK                               26
--- DELETE                                 16
--- LOGOFF BY CLEANUP                      16
--- EXECUTE                                10
--- UPDATE                                  3


SELECT ACTION_NAME, COUNT(*) AS TOTAL
FROM UNIFIED_AUDIT_TRAIL
WHERE DBUSERNAME = 'TRACEGP_PROD'
GROUP BY ACTION_NAME
ORDER BY TOTAL DESC;

--- Retorno esperado:
--- ACTION_NAME                    OBJECT_SCHEMA                  OBJECT_NAME                         TOTAL
--- ------------------------------ ------------------------------ ------------------------------ ----------
--- ALTER SESSION                                                                                       166
--- EXECUTE                                                                                              10

SELECT ACTION_NAME, OBJECT_SCHEMA, OBJECT_NAME, COUNT(*) AS TOTAL
FROM UNIFIED_AUDIT_TRAIL
WHERE DBUSERNAME = 'TRACEGP_PROD'
  AND ACTION_NAME IN ('EXECUTE', 'ALTER SESSION')
GROUP BY ACTION_NAME, OBJECT_SCHEMA, OBJECT_NAME
ORDER BY ACTION_NAME, TOTAL DESC;

--- Retorno esperado:
--- ALTER SESSION SET TIME_ZONE='America/Sao_Paulo' NLS_LANGUAGE='BRAZILIAN PORTUGUESE'  NLS_TERRITORY='BRAZIL'
--- ALTER SESSION SET NLS_LANGUAGE= 'AMERICAN' NLS_TERRITORY= 'AMERICA' NLS_CURRENCY= '$' NLS_ISO_CURRENCY= 'AMERICA' NLS_NUMERIC_CHARACTERS= '.,' NLS_CALENDAR= 'GREGORIAN' NLS_DATE_FORMAT= 'DD/MM/RR' NLS
--- ALTER SESSION SET TIME_ZONE='America/Sao_Paulo' NLS_LANGUAGE='AMERICAN'  NLS_TERRITORY='AMERICA'

SELECT DISTINCT DBMS_LOB.SUBSTR(SQL_TEXT, 200, 1) AS SQL_TEXT
FROM UNIFIED_AUDIT_TRAIL
WHERE DBUSERNAME = 'TRACEGP_PROD'
  AND ACTION_NAME = 'ALTER SESSION'
  AND SQL_TEXT IS NOT NULL
FETCH FIRST 10 ROWS ONLY;
