set lines 500
col name for a30
col cause for a10
col action for a30
col message for a80
select name, type, status,action,message from pdb_plug_in_violations where name='PDBSPCQA' and status <> 'RESOLVED';