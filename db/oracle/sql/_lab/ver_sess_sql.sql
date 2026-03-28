SELECT b.sid,
       b.serial#,
       a.sql_text,
       a.hash_value,
       b.userNAME,
       b.module
FROM   v$sqlarea a, v$session b	
WHERE  a.hash_value (+) = b.SQL_HASH_VALUE
and    upper(a.sql_text) like '%&1%'
/

undefine 1