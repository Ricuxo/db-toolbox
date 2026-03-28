-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2008 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_snapshot_database_10g.sql                                   |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : This SQL script provides a detailed report (in HTML format) on  |
-- |            all database metrics including installed options, storage,      |
-- |            performance data, and security.                                 |
-- | VERSION  : This script was designed for Oracle Database 10g Release 2.     |
-- |            Although this script will also work with Oracle Database 10g    |
-- |            Release 1, several sections will error out from missing tables  |
-- |            or columns.                                                     |
-- | USAGE    :                                                                 |
-- |                                                                            |
-- |    sqlplus -s <dba>/<password>@<TNS string> @dba_snapshot_database_10g.sql |
-- |                                                                            |
-- | TESTING  : This script has been successfully tested on the following       |
-- |            platforms:                                                      |
-- |                                                                            |
-- |              Linux      : Oracle Database 10.2.0.3.0                       |
-- |              Linux      : Oracle RAC 10.2.0.3.0                            |
-- |              Solaris    : Oracle Database 10.2.0.2.0                       |
-- |              Solaris    : Oracle Database 10.2.0.3.0                       |
-- |              Windows XP : Oracle Database 10.2.0.3.0                       |
-- |                                                                            |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

prompt
prompt +-----------------------------------------------------------------------------------------+
prompt |                             Snapshot Database 10g Release 2                             |
prompt |-----------------------------------------------------------------------------------------+
prompt | Copyright (c) 1998-2008 Jeffrey M. Hunter. All rights reserved. (www.idevelopment.info) |
prompt +-----------------------------------------------------------------------------------------+
prompt
prompt Creating database report.
prompt This script must be run as a user with SYSDBA privileges.
prompt This process can take several minutes to complete.
prompt

define reportHeader="<font size=+3 color=darkgreen><b>Oracle Database</b></font><hr>Copyright (c) 1998-2008 Jeffrey M. Hunter. All rights reserved. (Adapted by Cacildo Borges)<p>"

-- +----------------------------------------------------------------------------+
-- |                           SCRIPT SETTINGS                                  |
-- +----------------------------------------------------------------------------+

set termout       off
set echo          off
set feedback      off
set heading       off
set verify        off
set timing        off
set wrap          on
set trimspool     on
set serveroutput  on
set escape        on

set pagesize 50000
set linesize 175
set long     2000000000

clear buffer computes columns breaks

define fileName='C:\\Users\\henrique.silva\\Desktop\\TEMP\\dba_snapshot_database'
define versionNumber=5.3


-- +----------------------------------------------------------------------------+
-- |                   GATHER DATABASE REPORT INFORMATION                       |
-- +----------------------------------------------------------------------------+

COLUMN tdate NEW_VALUE _date NOPRINT
SELECT TO_CHAR(SYSDATE,'MM/DD/YYYY') tdate FROM dual;

COLUMN time NEW_VALUE _time NOPRINT
SELECT TO_CHAR(SYSDATE,'HH24:MI:SS') time FROM dual;

COLUMN date_time NEW_VALUE _date_time NOPRINT
SELECT TO_CHAR(SYSDATE,'MM/DD/YYYY HH24:MI:SS') date_time FROM dual;

COLUMN date_time_timezone NEW_VALUE _date_time_timezone NOPRINT
SELECT TO_CHAR(systimestamp, 'Mon DD, YYYY (') || TRIM(TO_CHAR(systimestamp, 'Day')) || TO_CHAR(systimestamp, ') "at" HH:MI:SS AM') || TO_CHAR(systimestamp, ' "in Timezone" TZR') date_time_timezone
FROM dual;

COLUMN spool_time NEW_VALUE _spool_time NOPRINT
SELECT TO_CHAR(SYSDATE,'YYYYMMDDHH24MI') spool_time FROM dual;

COLUMN dbname NEW_VALUE _dbname NOPRINT
SELECT name dbname FROM v$database;

COLUMN dbid NEW_VALUE _dbid NOPRINT
SELECT dbid dbid FROM v$database;

COLUMN platform_id NEW_VALUE _platform_id NOPRINT
SELECT platform_id platform_id FROM v$database;

COLUMN platform_name NEW_VALUE _platform_name NOPRINT
SELECT platform_name platform_name FROM v$database;

COLUMN global_name NEW_VALUE _global_name NOPRINT
SELECT global_name global_name FROM global_name;

COLUMN blocksize NEW_VALUE _blocksize NOPRINT
SELECT value blocksize FROM v$parameter WHERE name='db_block_size';

COLUMN startup_time NEW_VALUE _startup_time NOPRINT
SELECT TO_CHAR(startup_time, 'MM/DD/YYYY HH24:MI:SS') startup_time FROM v$instance;

COLUMN host_name NEW_VALUE _host_name NOPRINT
SELECT host_name host_name FROM v$instance;

COLUMN instance_name NEW_VALUE _instance_name NOPRINT
SELECT instance_name instance_name FROM v$instance;

COLUMN instance_number NEW_VALUE _instance_number NOPRINT
SELECT instance_number instance_number FROM v$instance;

COLUMN thread_number NEW_VALUE _thread_number NOPRINT
SELECT thread# thread_number FROM v$instance;

COLUMN cluster_database NEW_VALUE _cluster_database NOPRINT
SELECT value cluster_database FROM v$parameter WHERE name='cluster_database';

COLUMN cluster_database_instances NEW_VALUE _cluster_database_instances NOPRINT
SELECT value cluster_database_instances FROM v$parameter WHERE name='cluster_database_instances';

COLUMN reportRunUser NEW_VALUE _reportRunUser NOPRINT
SELECT user reportRunUser FROM dual;



-- +----------------------------------------------------------------------------+
-- |                   GATHER DATABASE REPORT INFORMATION                       |
-- +----------------------------------------------------------------------------+

set heading on

set markup html on spool on preformat off entmap on -
head ' -
  <title>Database Report</title> -
  <style type="text/css"> -
    body              {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    p                 {font:9pt Arial,Helvetica,sans-serif; color:black; background:White;} -
    table,tr,td       {font:9pt Arial,Helvetica,sans-serif; color:Black; background:#C0C0C0; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px;} -
    th                {font:bold 9pt Arial,Helvetica,sans-serif; color:#336699; background:#cccc99; padding:0px 0px 0px 0px;} -
    h1                {font:bold 12pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;} -
    h2                {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;} -
    a                 {font:9pt Arial,Helvetica,sans-serif; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.link            {font:9pt Arial,Helvetica,sans-serif; color:#663300; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLink          {font:9pt Arial,Helvetica,sans-serif; color:#663300; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkBlue      {font:9pt Arial,Helvetica,sans-serif; color:#0000ff; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkBlue  {font:9pt Arial,Helvetica,sans-serif; color:#000099; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkRed       {font:9pt Arial,Helvetica,sans-serif; color:#ff0000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkRed   {font:9pt Arial,Helvetica,sans-serif; color:#990000; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkGreen     {font:9pt Arial,Helvetica,sans-serif; color:#00ff00; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
    a.noLinkDarkGreen {font:9pt Arial,Helvetica,sans-serif; color:#009900; text-decoration: none; margin-top:0pt; margin-bottom:0pt; vertical-align:top;} -
  </style>' -
body   'BGCOLOR="#C0C0C0"' -
table  'WIDTH="90%" BORDER="1"'

spool &FileName._&_dbname._&_spool_time..html

set markup html on entmap off

-- +----------------------------------------------------------------------------+
-- |                             - REPORT HEADER -                              |
-- +----------------------------------------------------------------------------+

prompt <a name=top></a>
prompt &reportHeader

-- +----------------------------------------------------------------------------+
-- |                             - REPORT INDEX -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="report_index"></a>


prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Report Index</b></font><hr align="center" width="250"></center> -
<table width="90%" border="1"> -
<tr><th colspan="4">Database and Instance Information</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#report_header">Report Header</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#version">Version</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#options">Options</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#database_registry">Database Registry</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#feature_usage_statistics">Feature Usage Statistics</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#high_water_mark_statistics">High Water Mark Statistics</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#instance_overview">Instance Overview</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#database_overview">Database Overview</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#initialization_parameters">Initialization Parameters</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#control_files">Control Files</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#control_file_records">Control File Records</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#online_redo_logs">Online Redo Logs</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#redo_log_switches">Redo Log Switches</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#outstanding_alerts">Outstanding Alerts</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#statistics_level">Statistics Level</a></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr>


prompt -
<tr><th colspan="4">Scheduler / Jobs</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#jobs">Jobs</a></td> -
<td nowrap align="center" width="25%"><br></td> -
<td nowrap align="center" width="25%"><br></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr> -
<tr><th colspan="4">Storage</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#tablespaces">Tablespaces</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#data_files">Data Files</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#database_growth">Database Growth</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#tablespace_extents">Tablespace Extents</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#tablespace_to_owner">Tablespace to Owner</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#owner_to_tablespace">Owner to Tablespace</a></td> -
<td nowrap align="center" width="25%"><br></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr>


prompt -
<tr><th colspan="4">UNDO Segments</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#undo_segments">UNDO Segments</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#undo_segment_contention">UNDO Segment Contention</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#undo_retention_parameters">UNDO Retention Parameters</a></td> -
<td nowrap align="center" width="25%"><br></td> -
</tr>


prompt -
<tr><th colspan="4">Backups</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_jobs">RMAN Backup Jobs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_configuration">RMAN Configuration</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_sets">RMAN Backup Sets</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_pieces">RMAN Backup Pieces</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_control_files">RMAN Backup Control Files</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rman_backup_spfile">RMAN Backup SPFILE</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#archiving_mode">Archiving Mode</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#archive_destinations">Archive Destinations</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#archiving_instance_parameters">Archiving Instance Parameters</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#archiving_history">Archiving History</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#flash_recovery_area_parameters">Flash Recovery Area Parameters</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#flash_recovery_area_status">Flash Recovery Area Status</a></td> -
</tr>


prompt -
<tr><th colspan="4">Flashback Technologies</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#undo_retention_parameters">UNDO Retention Parameters</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#flashback_database_parameters">Flashback Database Parameters</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#flashback_database_status">Flashback Database Status</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#flashback_database_redo_time_matrix">Flashback Database Redo Time Matrix</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_recycle_bin">Recycle Bin</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
</tr>


prompt -
<tr><th colspan="4">Performance</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#sga_information">SGA Information</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#sga_target_advice">SGA Target Advice</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#sga_asmm_dynamic_components">SGA (ASMM) Dynamic Components</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#pga_target_advice">PGA Target Advice</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#file_io_statistics">File I/O Statistics</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#file_io_timings">File I/O Timings</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#average_overall_io_per_sec">Average Overall I/O per Second</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#redo_log_contention">Redo Log Contention</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#full_table_scans">Full Table Scans</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#sorts">Sorts</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_outlines">Outlines</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_outline_hints">Outline Hints</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#sql_statements_with_most_buffer_gets">SQL Statements With Most Buffer Gets</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#sql_statements_with_most_disk_reads">SQL Statements With Most Disk Reads</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_enabled_traces">Enabled Traces</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_enabled_aggregations">Enabled Aggregations</a></td> -
</tr>


prompt -
<tr><th colspan="4">Automatic Workload Repository - (AWR)</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#awr_workload_repository_information">Workload Repository Information</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#awr_snapshot_settings">AWR Snapshot Settings</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#awr_snapshot_list">AWR Snapshot List</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#awr_snapshot_size_estimates">AWR Snapshot Size Estimates</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#awr_baselines">AWR Baselines</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
</tr> -
<tr><th colspan="4">Sessions</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#current_sessions">Current Sessions</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#user_session_matrix">User Session Matrix</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_enabled_traces">Enabled Traces</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_enabled_aggregations">Enabled Aggregations</a></td> -
</tr>


prompt -
<tr><th colspan="4">Security</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#user_accounts">User Accounts</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#users_with_dba_privileges">Users With DBA Privileges</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#roles">Roles</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#default_passwords">Default Passwords</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#db_links">DB Links</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
</tr>


prompt -
<tr><th colspan="4">Objects</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#object_summary">Object Summary</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#segment_summary">Segment Summary</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#top_100_segments_by_size">Top 100 Segments (by size)</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#top_100_segments_by_extents">Top 100 Segments (by number of extents)</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_directories">Directories</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_directory_privileges">Directory Privileges</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_libraries">Libraries</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_types">Types</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_type_attributes">Type Attributes</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_type_methods">Type Methods</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_collections">Collections</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_lob_segments">LOB Segments</a></td> -
</tr>


prompt -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#objects_unable_to_extend">Objects Unable to Extend</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#objects_which_are_nearing_maxextents">Objects Which Are Nearing MAXEXTENTS</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#invalid_objects">Invalid Objects</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#procedural_object_errors">Procedural Object Errors</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#objects_without_statistics">Objects Without Statistics</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#tables_suffering_from_row_chaining_migration">Tables Suffering From Row Chaining/Migration</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#users_with_default_tablespace_defined_as_system">Users With Default Tablespace - (SYSTEM)</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#users_with_default_temporary_tablespace_as_system">Users With Default Temp Tablespace - (SYSTEM)</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#objects_in_the_system_tablespace">Objects in the SYSTEM Tablespace</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_recycle_bin">Recycle Bin</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
</tr>


prompt -
<tr><th colspan="4">Online Analytical Processing - (OLAP)</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_dimensions">Dimensions</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_dimension_levels">Dimension Levels</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_dimension_attributes">Dimension Attributes</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_dimension_hierarchies">Dimension Hierarchies</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_cubes">Cubes</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_olap_materialized_views">Materialized Views</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_olap_materialized_view_logs">Materialized View Logs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#dba_olap_materialized_view_refresh_groups">Materialized View Refresh Groups</a></td> -
</tr>


prompt -
<tr><th colspan="4">Data Pump</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#data_pump_jobs">Data Pump Jobs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#data_pump_sessions">Data Pump Sessions</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#data_pump_job_progress">Data Pump Job Progress</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
</tr>


prompt -
<tr><th colspan="4">Networking</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#mts_dispatcher_statistics">MTS Dispatcher Statistics</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#mts_dispatcher_response_queue_wait_stats">MTS Dispatcher Response Queue Wait Stats</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#mts_shared_server_wait_statistics">MTS Shared Server Wait Statistics</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#"><br></a></td> -
</tr>


prompt -
<tr><th colspan="4">Replication</th></tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#replication_summary">Replication Summary</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#deferred_transactions">Deferred Transactions</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#administrative_request_jobs">Administrative Request Jobs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#rep_initialization_parameters">Initialization Parameters</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#schedule_purge_jobs">(Schedule) - Purge Jobs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#schedule_push_jobs">(Schedule) - Push Jobs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#schedule_refresh_jobs">(Schedule) - Refresh Jobs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#multimaster_master_groups">(Multi-Master) - Master Groups</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#multimaster_master_groups_and_sites">(Multi-Master) - Master Groups and Sites</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#materialized_view_master_site_summary">(Materialized View) - Master Site Summary</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#materialized_view_master_site_logs">(Materialized View) - Master Site Logs</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#materialized_view_master_site_templates">(Materialized View) - Master Site Templates</a></td> -
</tr> -
<tr> -
<td nowrap align="center" width="25%"><a class="link" href="#materialized_view_summary">(Materialized View) - Summary</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#materialized_view_groups">(Materialized View) - Groups</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#materialized_view_materialized_views">(Materialized View) - Materialized Views</a></td> -
<td nowrap align="center" width="25%"><a class="link" href="#materialized_view_refresh_groups">(Materialized View) - Refresh Groups</a></td> -
</tr> -
</table>

prompt <p>


-- +============================================================================+
-- |                                                                            |
-- |        <<<<<     Database and Instance Information    >>>>>                |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Database and Instance Information</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                            - REPORT HEADER -                               |
-- +----------------------------------------------------------------------------+

prompt
prompt <a name="report_header"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Report Header</b></font><hr align="left" width="460">

prompt <table width="90%" border="1"> -
<tr><th align="left" width="20%">Report Name</th><td width="80%"><tt>&FileName._&_dbname._&_spool_time..html</tt></td></tr> -
<tr><th align="left" width="20%">Snapshot Database Version</th><td width="80%"><tt>&versionNumber</tt></td></tr> -
<tr><th align="left" width="20%">Run Date / Time / Timezone</th><td width="80%"><tt>&_date_time_timezone</tt></td></tr> -
<tr><th align="left" width="20%">Host Name</th><td width="80%"><tt>&_host_name</tt></td></tr> -
<tr><th align="left" width="20%">Database Name</th><td width="80%"><tt>&_dbname</tt></td></tr> -
<tr><th align="left" width="20%">Database ID</th><td width="80%"><tt>&_dbid</tt></td></tr> -
<tr><th align="left" width="20%">Global Database Name</th><td width="80%"><tt>&_global_name</tt></td></tr> -
<tr><th align="left" width="20%">Platform Name / ID</th><td width="80%"><tt>&_platform_name / &_platform_id</tt></td></tr> -
<tr><th align="left" width="20%">Clustered Database?</th><td width="80%"><tt>&_cluster_database</tt></td></tr> -
<tr><th align="left" width="20%">Clustered Database Instances</th><td width="80%"><tt>&_cluster_database_instances</tt></td></tr> -
<tr><th align="left" width="20%">Instance Name</th><td width="80%"><tt>&_instance_name</tt></td></tr> -
<tr><th align="left" width="20%">Instance Number</th><td width="80%"><tt>&_instance_number</tt></td></tr> -
<tr><th align="left" width="20%">Thread Number</th><td width="80%"><tt>&_thread_number</tt></td></tr> -
<tr><th align="left" width="20%">Database Startup Time</th><td width="80%"><tt>&_startup_time</tt></td></tr> -
<tr><th align="left" width="20%">Database Block Size</th><td width="80%"><tt>&_blocksize</tt></td></tr> -
<tr><th align="left" width="20%">Report Run User</th><td width="80%"><tt>&_reportRunUser</tt></td></tr> -
</table>

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- SET TIMING ON




-- +----------------------------------------------------------------------------+
-- |                                 - VERSION -                                |
-- +----------------------------------------------------------------------------+

prompt <a name="version"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Version</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN banner   FORMAT a120   HEADING 'Banner'

SELECT * FROM v$version;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                                 - OPTIONS -                                |
-- +----------------------------------------------------------------------------+

prompt <a name="options"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Options</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN parameter      HEADING 'Option Name'      ENTMAP off
COLUMN value          HEADING 'Installed?'       ENTMAP off

SELECT
    DECODE(   value
            , 'FALSE'
            , '<b><font color="#336699">' || parameter || '</font></b>'
            , '<b><font color="#336699">' || parameter || '</font></b>') parameter
  , DECODE(   value
            , 'FALSE'
            , '<div align="center"><font color="#990000"><b>' || value || '</b></font></div>'
            , '<div align="center">' || value || '</div>' ) value
FROM v$option
ORDER BY parameter;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                         - DATABASE REGISTRY -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="database_registry"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Database Registry</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN comp_id       FORMAT a75   HEADING 'Component ID'       ENTMAP off
COLUMN comp_name     FORMAT a75   HEADING 'Component Name'     ENTMAP off
COLUMN version                    HEADING 'Version'            ENTMAP off
COLUMN status        FORMAT a75   HEADING 'Status'             ENTMAP off
COLUMN modified      FORMAT a75   HEADING 'Modified'           ENTMAP off
COLUMN control                    HEADING 'Control'            ENTMAP off
COLUMN schema                     HEADING 'Schema'             ENTMAP off
COLUMN procedure                  HEADING 'Procedure'          ENTMAP off

SELECT
    '<font color="#336699"><b>' || comp_id    || '</b></font>' comp_id
  , '<div nowrap>' || comp_name || '</div>'                    comp_name
  , version
  , DECODE(   status
            , 'VALID',   '<div align="center"><b><font color="darkgreen">' || status || '</font></b></div>'
            , 'INVALID', '<div align="center"><b><font color="#990000">'   || status || '</font></b></div>'
            ,            '<div align="center"><b><font color="#663300">'   || status || '</font></b></div>' ) status
  , '<div nowrap align="right">' || modified || '</div>'                      modified
  , control
  , schema
  , procedure
FROM dba_registry
ORDER BY comp_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - INSTANCE OVERVIEW -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="instance_overview"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Instance Overview</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print       FORMAT a75    HEADING 'Instance|Name'       ENTMAP off
COLUMN instance_number_print     FORMAT a75    HEADING 'Instance|Num'        ENTMAP off
COLUMN thread_number_print                     HEADING 'Thread|Num'          ENTMAP off
COLUMN host_name_print           FORMAT a75    HEADING 'Host|Name'           ENTMAP off
COLUMN version                                 HEADING 'Oracle|Version'      ENTMAP off
COLUMN start_time                FORMAT a75    HEADING 'Start|Time'          ENTMAP off
COLUMN uptime                                  HEADING 'Uptime|(in days)'    ENTMAP off
COLUMN parallel                  FORMAT a75    HEADING 'Parallel - (RAC)'    ENTMAP off
COLUMN instance_status           FORMAT a75    HEADING 'Instance|Status'     ENTMAP off
COLUMN database_status           FORMAT a75    HEADING 'Database|Status'     ENTMAP off
COLUMN logins                    FORMAT a75    HEADING 'Logins'              ENTMAP off
COLUMN archiver                  FORMAT a75    HEADING 'Archiver'            ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>' || instance_name || '</b></font></div>'         instance_name_print
  , '<div align="center">' || instance_number || '</div>'                                           instance_number_print
  , '<div align="center">' || thread#         || '</div>'                                           thread_number_print
  , '<div align="center">' || host_name       || '</div>'                                           host_name_print
  , '<div align="center">' || version         || '</div>'                                           version
  , '<div align="center">' || TO_CHAR(startup_time,'mm/dd/yyyy HH24:MI:SS') || '</div>'             start_time
  , ROUND(TO_CHAR(SYSDATE-startup_time), 2)                                                         uptime
  , '<div align="center">' || parallel        || '</div>'                                           parallel
  , '<div align="center">' || status          || '</div>'                                           instance_status
  , '<div align="center">' || logins          || '</div>'                                           logins
  , DECODE(   archiver
            , 'FAILED'
            , '<div align="center"><b><font color="#990000">'   || archiver || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || archiver || '</font></b></div>') archiver
FROM gv$instance
ORDER BY instance_number;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                           - DATABASE OVERVIEW -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="database_overview"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Database Overview</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name                            FORMAT a75     HEADING 'Database|Name'              ENTMAP off
COLUMN dbid                                           HEADING 'Database|ID'                ENTMAP off
COLUMN db_unique_name                                 HEADING 'Database|Unique Name'       ENTMAP off
COLUMN creation_date                                  HEADING 'Creation|Date'              ENTMAP off
COLUMN platform_name_print                            HEADING 'Platform|Name'              ENTMAP off
COLUMN current_scn                                    HEADING 'Current|SCN'                ENTMAP off
COLUMN log_mode                                       HEADING 'Log|Mode'                   ENTMAP off
COLUMN open_mode                                      HEADING 'Open|Mode'                  ENTMAP off
COLUMN force_logging                                  HEADING 'Force|Logging'              ENTMAP off
COLUMN flashback_on                                   HEADING 'Flashback|On?'              ENTMAP off
COLUMN controlfile_type                               HEADING 'Controlfile|Type'           ENTMAP off
COLUMN last_open_incarnation_number                   HEADING 'Last Open|Incarnation Num'  ENTMAP off

SELECT
    '<div align="center"><font color="#336699"><b>'  || name  || '</b></font></div>'          name
  , '<div align="center">' || dbid                   || '</div>'                              dbid
  , '<div align="center">' || db_unique_name         || '</div>'                              db_unique_name
  , '<div align="center">' || TO_CHAR(created, 'mm/dd/yyyy HH24:MI:SS') || '</div>'           creation_date
  , '<div align="center">' || platform_name          || '</div>'                              platform_name_print
  , '<div align="center">' || current_scn            || '</div>'                              current_scn
  , '<div align="center">' || log_mode               || '</div>'                              log_mode
  , '<div align="center">' || open_mode              || '</div>'                              open_mode
  , '<div align="center">' || force_logging          || '</div>'                              force_logging
  , '<div align="center">' || flashback_on           || '</div>'                              flashback_on
  , '<div align="center">' || controlfile_type       || '</div>'                              controlfile_type
  , '<div align="center">' || last_open_incarnation# || '</div>'                              last_open_incarnation_number
FROM v$database;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                       - INITIALIZATION PARAMETERS -                        |
-- +----------------------------------------------------------------------------+

prompt <a name="initialization_parameters"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Initialization Parameters</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN spfile  HEADING 'SPFILE Usage'

SELECT
  'This database '||
  DECODE(   (1-SIGN(1-SIGN(count(*) - 0)))
          , 1
          , '<font color="#663300"><b>IS</b></font>'
          , '<font color="#990000"><b>IS NOT</b></font>') ||
  ' using an SPFILE.'spfile
FROM v$spparameter
WHERE value IS NOT null;


COLUMN pname                FORMAT a75    HEADING 'Parameter Name'    ENTMAP off
COLUMN instance_name_print  FORMAT a45    HEADING 'Instance Name'     ENTMAP off
COLUMN value                FORMAT a75    HEADING 'Value'             ENTMAP off
COLUMN isdefault            FORMAT a75    HEADING 'Is Default?'       ENTMAP off
COLUMN issys_modifiable     FORMAT a75    HEADING 'Is Dynamic?'       ENTMAP off

BREAK ON report ON pname

SELECT
    DECODE(   p.isdefault
            , 'FALSE'
            , '<b><font color="#336699">' || SUBSTR(p.name,0,512) || '</font></b>'
            , '<b><font color="#336699">' || SUBSTR(p.name,0,512) || '</font></b>' )    pname
  , DECODE(   p.isdefault
            , 'FALSE'
            , '<font color="#663300"><b>' || i.instance_name || '</b></font>'
            , i.instance_name )                                                         instance_name_print
  , DECODE(   p.isdefault
            , 'FALSE'
            , '<font color="#663300"><b>' || SUBSTR(p.value,0,512) || '</b></font>'
            , SUBSTR(p.value,0,512) ) value
  , DECODE(   p.isdefault
            , 'FALSE'
            , '<div align="center"><font color="#663300"><b>' || p.isdefault || '</b></font></div>'
            , '<div align="center">'                          || p.isdefault || '</div>')                         isdefault
  , DECODE(   p.isdefault
            , 'FALSE'
            , '<div align="right"><font color="#663300"><b>' || p.issys_modifiable || '</b></font></div>'
            , '<div align="right">'                          || p.issys_modifiable || '</div>')                  issys_modifiable
FROM
    gv$parameter p
  , gv$instance  i
WHERE
    p.inst_id = i.inst_id
ORDER BY
    p.name
  , i.instance_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                            - CONTROL FILES -                               |
-- +----------------------------------------------------------------------------+

prompt <a name="control_files"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Control Files</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN name                           HEADING 'Controlfile Name'  ENTMAP off
COLUMN status           FORMAT a75    HEADING 'Status'            ENTMAP off
COLUMN file_size        FORMAT a75    HEADING 'File Size'         ENTMAP off

SELECT
    '<tt>' || c.name || '</tt>'                                                                      name
  , DECODE(   c.status
            , NULL
            ,  '<div align="center"><b><font color="darkgreen">VALID</font></b></div>'
            ,  '<div align="center"><b><font color="#663300">'   || c.status || '</font></b></div>') status
  , '<div align="right">' || TO_CHAR(block_size *  file_size_blks, '999,999,999,999') || '</div>'    file_size
FROM
    v$controlfile c
ORDER BY
    c.name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                         - CONTROL FILE RECORDS -                           |
-- +----------------------------------------------------------------------------+

prompt <a name="control_file_records"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Control File Records</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN type           FORMAT          a95    HEADING 'Record Section Type'      ENTMAP off
COLUMN record_size    FORMAT       999,999   HEADING 'Record Size|(in bytes)'   ENTMAP off
COLUMN records_total  FORMAT       999,999   HEADING 'Records Allocated'        ENTMAP off
COLUMN bytes_alloc    FORMAT   999,999,999   HEADING 'Bytes Allocated'          ENTMAP off
COLUMN records_used   FORMAT       999,999   HEADING 'Records Used'             ENTMAP off
COLUMN bytes_used     FORMAT   999,999,999   HEADING 'Bytes Used'               ENTMAP off
COLUMN pct_used       FORMAT          B999   HEADING '% Used'                   ENTMAP off
COLUMN first_index                           HEADING 'First Index'              ENTMAP off
COLUMN last_index                            HEADING 'Last Index'               ENTMAP off
COLUMN last_recid                            HEADING 'Last RecID'               ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>'   of record_size records_total bytes_alloc records_used bytes_used ON report
COMPUTE avg LABEL '<font color="#990000"><b>Average: </b></font>' of pct_used      ON report

SELECT
    '<div align="left"><font color="#336699"><b>' || type || '</b></font></div>'  type
  , record_size                                       record_size
  , records_total                                     records_total
  , (records_total * record_size)                     bytes_alloc
  , records_used                                      records_used
  , (records_used * record_size)                      bytes_used
  , NVL(records_used/records_total * 100, 0)          pct_used
  , first_index                                       first_index
  , last_index                                        last_index
  , last_recid                                        last_recid
FROM v$controlfile_record_section
ORDER BY type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                          - ONLINE REDO LOGS -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="online_redo_logs"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Online Redo Logs</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN instance_name_print  FORMAT a95                HEADING 'Instance Name'    ENTMAP off
COLUMN thread_number_print  FORMAT a95                HEADING 'Thread Number'    ENTMAP off
COLUMN groupno                                        HEADING 'Group Number'     ENTMAP off
COLUMN member                                         HEADING 'Member'           ENTMAP off
COLUMN redo_file_type       FORMAT a75                HEADING 'Redo Type'        ENTMAP off
COLUMN log_status           FORMAT a75                HEADING 'Log Status'       ENTMAP off
COLUMN bytes                FORMAT 999,999,999,999    HEADING 'Bytes'            ENTMAP off
COLUMN archived             FORMAT a75                HEADING 'Archived?'        ENTMAP off

BREAK ON report ON instance_name_print ON thread_number_print

SELECT
    '<div align="center"><font color="#336699"><b>' || i.instance_name || '</b></font></div>'        instance_name_print
  , '<div align="center">' || i.thread# || '</div>'                                                  thread_number_print
  , f.group#                                                                                         groupno
  , '<tt>' || f.member || '</tt>'                                                                    member
  , f.type                                                                                           redo_file_type
  , DECODE(   l.status
            , 'CURRENT'
            , '<div align="center"><b><font color="darkgreen">' || l.status || '</font></b></div>'
            , '<div align="center"><b><font color="#990000">'   || l.status || '</font></b></div>')  log_status
  , l.bytes                                                                                          bytes
  , '<div align="center">'  || l.archived || '</div>'                                                archived
FROM
    gv$logfile  f
  , gv$log      l
  , gv$instance i
WHERE
      f.group#  = l.group#
  AND l.thread# = i.thread#
  AND i.inst_id = f.inst_id
  AND f.inst_id = l.inst_id
ORDER BY
    i.instance_name
  , f.group#
  , f.member;


prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                         - REDO LOG SWITCHES -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="redo_log_switches"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Redo Log Switches</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN DAY   FORMAT a75              HEADING 'Day / Time'  ENTMAP off
COLUMN H00   FORMAT 999,999B         HEADING '00'          ENTMAP off
COLUMN H01   FORMAT 999,999B         HEADING '01'          ENTMAP off
COLUMN H02   FORMAT 999,999B         HEADING '02'          ENTMAP off
COLUMN H03   FORMAT 999,999B         HEADING '03'          ENTMAP off
COLUMN H04   FORMAT 999,999B         HEADING '04'          ENTMAP off
COLUMN H05   FORMAT 999,999B         HEADING '05'          ENTMAP off
COLUMN H06   FORMAT 999,999B         HEADING '06'          ENTMAP off
COLUMN H07   FORMAT 999,999B         HEADING '07'          ENTMAP off
COLUMN H08   FORMAT 999,999B         HEADING '08'          ENTMAP off
COLUMN H09   FORMAT 999,999B         HEADING '09'          ENTMAP off
COLUMN H10   FORMAT 999,999B         HEADING '10'          ENTMAP off
COLUMN H11   FORMAT 999,999B         HEADING '11'          ENTMAP off
COLUMN H12   FORMAT 999,999B         HEADING '12'          ENTMAP off
COLUMN H13   FORMAT 999,999B         HEADING '13'          ENTMAP off
COLUMN H14   FORMAT 999,999B         HEADING '14'          ENTMAP off
COLUMN H15   FORMAT 999,999B         HEADING '15'          ENTMAP off
COLUMN H16   FORMAT 999,999B         HEADING '16'          ENTMAP off
COLUMN H17   FORMAT 999,999B         HEADING '17'          ENTMAP off
COLUMN H18   FORMAT 999,999B         HEADING '18'          ENTMAP off
COLUMN H19   FORMAT 999,999B         HEADING '19'          ENTMAP off
COLUMN H20   FORMAT 999,999B         HEADING '20'          ENTMAP off
COLUMN H21   FORMAT 999,999B         HEADING '21'          ENTMAP off
COLUMN H22   FORMAT 999,999B         HEADING '22'          ENTMAP off
COLUMN H23   FORMAT 999,999B         HEADING '23'          ENTMAP off
COLUMN TOTAL FORMAT 999,999,999      HEADING 'Total'       ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total:</b></font>' avg label '<font color="#990000"><b>Average:</b></font>' OF total ON report

SELECT
    '<div align="center"><font color="#336699"><b>' || SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)  || '</b></font></div>'  DAY
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'00',1,0)) H00
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'01',1,0)) H01
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'02',1,0)) H02
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'03',1,0)) H03
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'04',1,0)) H04
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'05',1,0)) H05
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'06',1,0)) H06
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'07',1,0)) H07
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'08',1,0)) H08
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'09',1,0)) H09
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'10',1,0)) H10
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'11',1,0)) H11
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'12',1,0)) H12
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'13',1,0)) H13
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'14',1,0)) H14
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'15',1,0)) H15
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'16',1,0)) H16
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'17',1,0)) H17
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'18',1,0)) H18
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'19',1,0)) H19
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'20',1,0)) H20
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'21',1,0)) H21
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'22',1,0)) H22
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH24:MI:SS'),10,2),'23',1,0)) H23
  , COUNT(*)                                                                      TOTAL
FROM
  v$log_history  a
GROUP BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)
ORDER BY SUBSTR(TO_CHAR(first_time, 'MM/DD/RR HH:MI:SS'),1,5)
/

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>

-- +============================================================================+
-- |                                                                            |
-- |                      <<<<<     STORAGE    >>>>>                            |
-- |                                                                            |
-- +============================================================================+


prompt
prompt <center><font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#663300"><b><u>Storage</u></b></font></center>


-- +----------------------------------------------------------------------------+
-- |                            - TABLESPACES -                                 |
-- +----------------------------------------------------------------------------+

prompt <a name="tablespaces"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Tablespaces</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN status                                  HEADING 'Status'            ENTMAP off
COLUMN name                                    HEADING 'Tablespace Name'   ENTMAP off
COLUMN type        FORMAT a12                  HEADING 'TS Type'           ENTMAP off
COLUMN extent_mgt  FORMAT a10                  HEADING 'Ext. Mgt.'         ENTMAP off
COLUMN segment_mgt FORMAT a9                   HEADING 'Seg. Mgt.'         ENTMAP off
COLUMN ts_size     FORMAT 999,999,999,999,999  HEADING 'Tablespace Size'   ENTMAP off
COLUMN free        FORMAT 999,999,999,999,999  HEADING 'Free (in bytes)'   ENTMAP off
COLUMN used        FORMAT 999,999,999,999,999  HEADING 'Used (in bytes)'   ENTMAP off
COLUMN pct_used                                HEADING 'Pct. Used'         ENTMAP off

BREAK ON report
COMPUTE SUM label '<font color="#990000"><b>Total:</b></font>'   OF ts_size used free ON report

SELECT
    DECODE(   d.status
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || d.status || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || d.status || '</font></b></div>') status
  , '<b><font color="#336699">' || d.tablespace_name || '</font></b>'                               name
  , d.contents                                          type
  , d.extent_management                                 extent_mgt
  , d.segment_space_management                          segment_mgt
  , NVL(a.bytes, 0)                                     ts_size
  , NVL(f.bytes, 0)                                     free
  , NVL(a.bytes - NVL(f.bytes, 0), 0)                   used
  , '<div align="right"><b>' ||
          DECODE (
              (1-SIGN(1-SIGN(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0)) - 90)))
            , 1
            , '<font color="#990000">'   || TO_CHAR(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0))) || '</font>'
            , '<font color="darkgreen">' || TO_CHAR(TRUNC(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0))) || '</font>'
          )
    || '</b> %</div>' pct_used
FROM
    sys.dba_tablespaces d
  , ( select tablespace_name, sum(bytes) bytes
      from dba_data_files
      group by tablespace_name
    ) a
  , ( select tablespace_name, sum(bytes) bytes
      from dba_free_space
      group by tablespace_name
    ) f
WHERE
      d.tablespace_name = a.tablespace_name(+)
  AND d.tablespace_name = f.tablespace_name(+)
  AND NOT (
    d.extent_management like 'LOCAL'
    AND
    d.contents like 'TEMPORARY'
  )
UNION ALL
SELECT
    DECODE(   d.status
            , 'OFFLINE'
            , '<div align="center"><b><font color="#990000">'   || d.status || '</font></b></div>'
            , '<div align="center"><b><font color="darkgreen">' || d.status || '</font></b></div>') status
  , '<b><font color="#336699">' || d.tablespace_name  || '</font></b>'                              name
  , d.contents                                   type
  , d.extent_management                          extent_mgt
  , d.segment_space_management                   segment_mgt
  , NVL(a.bytes, 0)                              ts_size
  , NVL(a.bytes - NVL(t.bytes,0), 0)             free
  , NVL(t.bytes, 0)                              used
  , '<div align="right"><b>' ||
          DECODE (
              (1-SIGN(1-SIGN(TRUNC(NVL(t.bytes / a.bytes * 100, 0)) - 90)))
            , 1
            , '<font color="#990000">'   || TO_CHAR(TRUNC(NVL(t.bytes / a.bytes * 100, 0))) || '</font>'
            , '<font color="darkgreen">' || TO_CHAR(TRUNC(NVL(t.bytes / a.bytes * 100, 0))) || '</font>'
          )
    || '</b> %</div>' pct_used
FROM
    sys.dba_tablespaces d
  , ( select tablespace_name, sum(bytes) bytes
      from dba_temp_files
      group by tablespace_name
    ) a
  , ( select tablespace_name, sum(bytes_cached) bytes
      from v$temp_extent_pool
      group by tablespace_name
    ) t
WHERE
      d.tablespace_name = a.tablespace_name(+)
  AND d.tablespace_name = t.tablespace_name(+)
  AND d.extent_management like 'LOCAL'
  AND d.contents like 'TEMPORARY'
ORDER BY 2;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                            - DATA FILES -                                  |
-- +----------------------------------------------------------------------------+

prompt <a name="data_files"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Data Files</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN tablespace                                   HEADING 'Tablespace Name / File Class'  ENTMAP off
COLUMN filename                                     HEADING 'Filename'                      ENTMAP off
COLUMN filesize        FORMAT 999,999,999,999,999   HEADING 'File Size'                     ENTMAP off
COLUMN autoextensible                               HEADING 'Autoextensible'                ENTMAP off
COLUMN increment_by    FORMAT 999,999,999,999,999   HEADING 'Next'                          ENTMAP off
COLUMN maxbytes        FORMAT 999,999,999,999,999   HEADING 'Max'                           ENTMAP off

BREAK ON report
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' OF filesize ON report

SELECT /*+ ordered */
    '<font color="#336699"><b>' || d.tablespace_name  || '</b></font>'  tablespace
  , '<tt>' || d.file_name || '</tt>'                                    filename
  , d.bytes                                                             filesize
  , '<div align="center">' || NVL(d.autoextensible, '<br>') || '</div>' autoextensible
  , d.increment_by * e.value                                            increment_by
  , d.maxbytes                                                          maxbytes
FROM
    sys.dba_data_files d
  , v$datafile v
  , (SELECT value
     FROM v$parameter
     WHERE name = 'db_block_size') e
WHERE
  (d.file_name = v.name)
UNION
SELECT
    '<font color="#336699"><b>' || d.tablespace_name || '</b></font>'   tablespace
  , '<tt>' || d.file_name  || '</tt>'                                   filename
  , d.bytes                                                             filesize
  , '<div align="center">' || NVL(d.autoextensible, '<br>') || '</div>' autoextensible
  , d.increment_by * e.value                                            increment_by
  , d.maxbytes                                                          maxbytes
FROM
    sys.dba_temp_files d
  , (SELECT value
     FROM v$parameter
     WHERE name = 'db_block_size') e
UNION
SELECT
    '<font color="#336699"><b>[ ONLINE REDO LOG ]</b></font>'
  , '<tt>' || a.member || '</tt>'
  , b.bytes
  , null
  , null
  , null
FROM
    v$logfile a
  , v$log b
WHERE
    a.group# = b.group#
UNION
SELECT
    '<font color="#336699"><b>[ CONTROL FILE    ]</b></font>'
  , '<tt>' || a.name || '</tt>'
  , null
  , null
  , null
  , null
FROM
    v$controlfile a
ORDER BY
    1
  , 2;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>


-- +----------------------------------------------------------------------------+
-- |                        - TABLESPACE EXTENTS -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="tablespace_extents"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Tablespace Extents</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN tablespace_name                              HEADING 'Tablespace Name'         ENTMAP off
COLUMN largest_ext     FORMAT 999,999,999,999,999   HEADING 'Largest Extent'          ENTMAP off
COLUMN smallest_ext    FORMAT 999,999,999,999,999   HEADING 'Smallest Extent'         ENTMAP off
COLUMN total_free      FORMAT 999,999,999,999,999   HEADING 'Total Free'              ENTMAP off
COLUMN pieces          FORMAT 999,999,999,999,999   HEADING 'Number of Free Extents'  ENTMAP off

break on report
compute sum label '<font color="#990000"><b>Total:</b></font>' of largest_ext smallest_ext total_free pieces on report

SELECT
    '<b><font color="#336699">' || tablespace_name || '</font></b>' tablespace_name
  , max(bytes)       largest_ext
  , min(bytes)       smallest_ext
  , sum(bytes)       total_free
  , count(*)         pieces
FROM
    dba_free_space
GROUP BY
    tablespace_name
ORDER BY
    tablespace_name;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                        - TABLESPACE TO OWNER  -                            |
-- +----------------------------------------------------------------------------+

prompt <a name="tablespace_to_owner"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Tablespace to Owner</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN tablespace_name  FORMAT a75                  HEADING 'Tablespace Name'  ENTMAP off
COLUMN owner            FORMAT a75                  HEADING 'Owner'            ENTMAP off
COLUMN segment_type     FORMAT a75                  HEADING 'Segment Type'     ENTMAP off
COLUMN bytes            FORMAT 999,999,999,999,999  HEADING 'Size (in Bytes)'  ENTMAP off
COLUMN seg_count        FORMAT 999,999,999,999      HEADING 'Segment Count'    ENTMAP off

BREAK ON report ON tablespace_name
COMPUTE sum LABEL '<font color="#990000"><b>Total: </b></font>' of seg_count bytes ON report

SELECT
    '<font color="#336699"><b>' || tablespace_name || '</b></font>'  tablespace_name
  , '<div align="right">'       || owner           || '</div>'       owner
  , '<div align="right">'       || segment_type    || '</div>'       segment_type
  , sum(bytes)                                                       bytes
  , count(*)                                                         seg_count
FROM
    dba_segments
GROUP BY
    tablespace_name
  , owner
  , segment_type
ORDER BY
    tablespace_name
  , owner
  , segment_type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>




-- +----------------------------------------------------------------------------+
-- |                       - OWNER TO TABLESPACE -                              |
-- +----------------------------------------------------------------------------+

prompt <a name="owner_to_tablespace"></a>
prompt <font size="+2" face="Arial,Helvetica,Geneva,sans-serif" color="#336699"><b>Owner to Tablespace</b></font><hr align="left" width="460">

CLEAR COLUMNS BREAKS COMPUTES

COLUMN owner            FORMAT a75                  HEADING 'Owner'            ENTMAP off
COLUMN tablespace_name  FORMAT a75                  HEADING 'Tablespace Name'  ENTMAP off
COLUMN segment_type     FORMAT a75                  HEADING 'Segment Type'     ENTMAP off
COLUMN bytes            FORMAT 999,999,999,999,999  HEADING 'Size (in Bytes)'  ENTMAP off
COLUMN seg_count        FORMAT 999,999,999,999      HEADING 'Segment Count'    ENTMAP off

break on report on owner
compute sum label '<font color="#990000"><b>Total: </b></font>' of seg_count bytes on report

SELECT
    '<font color="#336699"><b>'  || owner           || '</b></font>' owner
  , '<div align="right">'        || tablespace_name || '</div>'      tablespace_name
  , '<div align="right">'        || segment_type    || '</div>'      segment_type
  , sum(bytes)                                                       bytes
  , count(*)                                                         seg_count
FROM
    dba_segments
GROUP BY
    owner
  , tablespace_name
  , segment_type
ORDER BY
    owner
  , tablespace_name
  , segment_type;

prompt <center>[<a class="noLink" href="#top">Top</a>]</center><p>



SPOOL OFF

SET MARKUP HTML OFF

SET TERMOUT ON

prompt
prompt Output written to: &FileName._&_dbname._&_spool_time..html
