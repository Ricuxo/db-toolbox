SET linesize 160 pagesize 200
col RECORD_ID FOR 9999999 head ID
col ORIGINATING_TIMESTAMP FOR a20 head DATE
col MESSAGE_TEXT FOR a120 head Message

SELECT 
    record_id,
    to_char(originating_timestamp,'DD.MM.YYYY HH24:MI:SS'),
    message_text 
FROM 
    x$dbgalertext
WHERE
originating_timestamp > (sysdate - &days)
--AND
--message_text like '%ORA-%';