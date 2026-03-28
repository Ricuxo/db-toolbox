set lines 155 pages 9999
col thread# for 9999990
col sequence# for 999999990
col grp for 990
col fnm for a50 head "File Name"
col "Fisrt SCN Number" for 999999999999990
break on thread
# skip 1
select a.thread#
,a.sequence#
,a.group# grp     
, a.bytes/1024/1024 Size_MB     
,a.status     
,a.archived     
,a.first_change# "First SCN Number"     
,to_char(FIRST_TIME,'DD-Mon-RR HH24:MI:SS') "First SCN Time"   
,to_char(LAST_TIME,'DD-Mon-RR HH24:MI:SS') "Last SCN Time"  from
 v$standby_log a  order by 1,2,3,4
 /