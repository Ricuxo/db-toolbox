col diskgroup for a20
col asm_compat for a20
col db_compat for a20
SELECT dg.name AS diskgroup, SUBSTR(d.name,1,16) AS asmdisk, d.label DiskLabel,
     SUBSTR(dg.compatibility,1,12) AS asm_compat,
     SUBSTR(dg.database_compatibility,1,12) AS db_compat
     FROM V$ASM_DISKGROUP dg, V$ASM_DISK d 
     WHERE dg.group_number = d.group_number;
