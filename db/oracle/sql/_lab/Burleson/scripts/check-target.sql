/*  */
REM CHECKTARGET.SQL
  REM
  REM This script should be used in conjunction with [NOTE:76670.1]
  REM to check a target database for the side effects of BUG:970640 
  REM
  REM For Oracle 8.1 ONLY
  REM To be run connected INTERNAL or as a SYSDBA user 
  REM
  REM SPOOL THE OUTPUT OF THIS SCRIPT
  REM 
  SET SERVEROUTPUT ON
  REM
  DECLARE
   --
    LIMIT   number:=2147483648;   /* Highest sensible object id   */
    MAXOBJ  number:=4294950911;   /* Max ever object id           */
    next_id number;               /* Current NEXT object_id       */
    high_id number;               /* Current Highest object_id    */
    best_id number;               /* Current Highest Object_id below LIMIT */
    badcnt  number:=0;            /* Number of objects with ID above LIMIT */
    dups    boolean:=false;       /* True if duplicate dataobj#   */
   --
   -- Cursor to get information on OBJECTs with ID above LIMIT
   --
    CURSOR bad_objects IS
      SELECT greatest(object_id, data_object_id) ID,
                  OBJECT_TYPE,OWNER, OBJECT_NAME, SUBOBJECT_NAME
        FROM dba_objects 
       WHERE object_id>=LIMIT OR data_object_id>=LIMIT
      ORDER BY 3,4,5
    ;
   --
   -- Cursor to check for DUPLICATE dataobj# which are not in a cluster
   --
    CURSOR Duplicates IS
          select obj# from obj$ o
           where o.dataobj# in 
           ( select dataobj# from obj$ g
             group by dataobj# having count(*) >1) 
           and not exists
           (select 1 from clu$ c where c.dataobj#=o.dataobj#)
          ;
    CURSOR ObjDesc(ID number) IS
          select * from dba_objects where object_id=id;
    --
  BEGIN
    dbms_output.enable(100000);
   --
    dbms_output.put_line('Checking target database for effects of Bug:970640');
   -- 
   -- First check for DUPLICATE dataobj#
   --
    FOR D in Duplicates
    LOOP
      IF not dups THEN
    dbms_output.put_line('.');
       dbms_output.put_line('** Warning: Objects exist with duplicate DATAOBJ#');
       dbms_output.put_line('** These objects should be checked'||
                            ' to ensure they are NOT in the same tablespace');
       dbms_output.put_line('.');
       dups:=true;
      END IF;
      FOR O in ObjDesc(D.obj#)
      LOOP
       dbms_output.put('. '||O.data_object_id||' ');
       dbms_output.put(O.owner||'.'||O.object_name||' '||O.subobject_name);
       dbms_output.put_line(' ('||O.object_type||')');
      END LOOP;
    END LOOP;
   -- 
   -- Get the NEXT OBJECT ID from the dictionary
   --
    SELECT dataobj# INTO next_id FROM obj$ WHERE name='_NEXT_OBJECT';
   -- 
   -- Get the highest OBJECT ID that looks sensible (below 2Gb)
   --
    SELECT max(id) INTO best_id FROM 
       (SELECT max(dataobj#) ID FROM obj$ 
         WHERE dataobj#<LIMIT and name!='_NEXT_OBJECT'
        UNION ALL
        SELECT max(obj#) ID FROM obj$ 
         WHERE obj#<LIMIT and name!='_NEXT_OBJECT'
       )
    ;
   -- 
   -- Get the actual highest object ID, whether good or bad
   --
    SELECT max(greatest(obj#,dataobj#)) INTO high_id FROM obj$ 
     WHERE name!='_NEXT_OBJECT';
   --
   -- Output findings
   --
    dbms_output.put_line('.');
    dbms_output.put_line('Base data:');
    dbms_output.put_line('.  NEXT OBJECT Id:    '||next_id);
    dbms_output.put_line('.  HIGHEST OBJECT Id: '||high_id);
    dbms_output.put_line('.  BEST OBJECT Id:    '||best_id);
   --
   -- Comment on findings
   --
    IF next_id>=LIMIT THEN
      dbms_output.put_line('.');
      dbms_output.put_line('NEXT OBJECT Id much too high');
    END IF;
   -- 
    IF high_id>=LIMIT THEN
     dbms_output.put_line('.');
     dbms_output.put_line('The objects listed below have very high object ids.');
     dbms_output.put_line('Determine if they can be dropped/rebuilt:');
     FOR R in bad_objects
     LOOP
       dbms_output.put('. '||R.owner||'.'||R.object_name||' '||R.subobject_name);
       dbms_output.put_line(' ('||R.object_type||')');
       badcnt:=badcnt+1;
     END LOOP;
    END IF;
   --
    IF high_id>=next_id THEN
      dbms_output.put_line('.');
      dbms_output.put_line('Some objects have IDs above "NEXT OBJECT"');
    END IF;
   --
    IF high_id>=LIMIT OR high_id>=next_id OR next_id>=LIMIT THEN
      dbms_output.put_line('.');
      dbms_output.put_line('** Corrective action is required by Oracle Support');
      dbms_output.put_line('** Information below for SUPPORT only');
      dbms_output.put_line('** Best option:');
      dbms_output.put('.     ');
      if badcnt>0 then
        dbms_output.put('DROP the above '||badcnt||' object/s and ');
      end if;
      dbms_output.put_line('RESET to '||(best_id+1));
      if high_id>=LIMIT THEN
        dbms_output.put_line('** Second option:');
        dbms_output.put_line('.     RESET to '||(high_id+1)||' leaving only '||
                  (maxobj-high_id-2)||' objects before DB is in trouble');
      end if;
      dbms_output.put_line('.');
      dbms_output.put('** Remember to RE-RUN this script IMMEDIATELY ');
      dbms_output.put_line('prior to any corrective action');
    ELSE
      IF not dups THEN
        dbms_output.put_line('** Database object IDs look OK');
      END IF;
    END IF;
    IF dups THEN
      dbms_output.put_line('.');
      dbms_output.put_line('** Remember to check the DUPLICATES above');
    END IF;
  END;
  /
       
  REM
