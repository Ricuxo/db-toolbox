PROMPT Read from v$backup_corruption
PROMPT
SELECT distinct 'Data Block# '|| block# || ' of Data File '
|| name || ' is corrupted.'
FROM v$backup_corruption a, v$datafile b
WHERE a.file# = b.file#;
PROMPT
PROMPT
PROMPT Read from v$copy_corruption
PROMPT
PROMPT
SELECT distinct 'Data Block# '|| block# || ' of Data File '
|| name || ' is corrupted.'
FROM v$copy_corruption a, v$datafile b
WHERE a.file# = b.file#;