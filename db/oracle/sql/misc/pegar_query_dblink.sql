SELECT inst_id, child_number, id, other
FROM gv$sql_plan
WHERE sql_id = 'fgvhqa9unzgs0'
  AND operation = 'REMOTE'
ORDER BY child_number, id;