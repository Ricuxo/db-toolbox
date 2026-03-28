SET LINESIZE 500
SET PAGESIZE 1000
SET SERVEROUT ON
SET LONG 2000000

COLUMN action_time FORMAT A20
COLUMN action FORMAT A10
COLUMN status FORMAT A10
COLUMN description FORMAT A40
COLUMN source_version FORMAT A10
COLUMN target_version FORMAT A10


alter session set "_exclude_seed_cdb_view"=FALSE;

select CON_ID,
        TO_CHAR(action_time, 'YYYY-MM-DD') AS action_time,
        PATCH_ID,
        PATCH_TYPE,
        ACTION,
        DESCRIPTION,
        SOURCE_VERSION,
        TARGET_VERSION,
        STATUS
   from CDB_REGISTRY_SQLPATCH
  order by CON_ID, action_time, patch_id;