-- current_requests.sql

SELECT
  INST_ID,
  sum(CR_REQUESTS) "CR Requests",
  sum(CURRENT_REQUESTS) "Current Requests"
FROM
  GV$CR_BLOCK_SERVER
GROUP BY
  INST_ID;