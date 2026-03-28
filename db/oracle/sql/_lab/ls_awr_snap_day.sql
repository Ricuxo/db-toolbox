PROMPT
PROMPT
PROMPT ### INstancias existentes
PROMPT ### views: gv$instance
PROMPT ####################################

select host_name, instance_number, instance_name from gv$INSTANCE
/

PROMPT
PROMPT
PROMPT ### SNAPSHOT do AWR por dias - uso @ls_awr_snap_day
PROMPT ### views dba_hist_snapshot, dba_hist_database_instance
PROMPT ###################################################################

ACCEPT num_days prompt "Numero Dias: "
ACCEPT inst_num prompt "Instance number: "

col snap_end_interval_time for a27

SELECT    di.instance_name inst_name ,
          di.db_name ,
          s.snap_id snap_id ,
          TO_CHAR(s.end_interval_time,'dd Mon YYYY HH24:mi') snap_end_interval_time
FROM      dba_hist_snapshot s ,
          dba_hist_database_instance di ,
          (SELECT TO_CHAR(MAX(end_interval_time),'dd/mm/yyyy') max_snap FROM dba_hist_snapshot) ms
WHERE     s.instance_number    = &&inst_num AND 
          di.dbid              = s.dbid AND 
          di.instance_number   = s.instance_number AND 
          di.startup_time      = s.startup_time AND 
          s.end_interval_time between (to_date(ms.max_snap) - (&&num_days-1)) and (to_date(ms.max_snap) - (&&num_days-3))
ORDER BY  db_name , instance_name , snap_id
/