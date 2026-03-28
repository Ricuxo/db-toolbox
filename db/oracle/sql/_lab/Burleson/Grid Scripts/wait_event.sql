-- wait_event.sql

SELECT
  inst_id "Instance",
  event "Wait Event",
  total_waits,
  time_waited
FROM
  GV$SYSTEM_EVENT
WHERE
      event in (
       'global cache busy',
       'buffer busy global cache',
       'buffer busy global CR')
ORDER BY
  INST_ID;