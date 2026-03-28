/*  */
UPDATE other_scripts a
SET a.date_edited = (SELECT distinct b.date_edited FROM sql_scripts b
WHERE a.script_name = b.script_name)

INSERT INTO other_scripts a
SELECT * FROM sql_scripts b
WHERE b.script_name not in (
select b.script_name from other_scripts b);

MERGE INTO other_scripts a
USING (SELECT * FROM sql_scripts) b
ON (a.script_name = b.script_name)
WHEN MATCHED THEN
UPDATE SET a.date_edited = b.date_edited
WHEN NOT MATCHED THEN
INSERT (a.permissions, a.filetype, a.owner, a.group_name,
a.size_in_bytes, a.date_edited,a.script_name )
VALUES (b.permissions, b.filetype, b.owner, b.group_name,
b.size_in_bytes, b.date_edited, b.script_name );
