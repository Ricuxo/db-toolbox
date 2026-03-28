--  Shared Pool Advisory

select d.dbid            dbid
     , d.name            db_name
     , i.instance_number inst_num
     , i.instance_name   inst_name
  from v$database d,
       v$instance i;


ttitle lef 'Shared Pool Advisory for '-
           'DB: ' db_name  '  Instance: ' inst_name '  '-
           'End Snap: ' format 99999999 end_snap -
       skip 1 -
       lef '-> Note there is often a 1:Many correlation between a single logical object' -
       skip 1 -
       lef '   in the Library Cache, and the physical number of memory objects associated' -
       skip 1 -
       lef '   with it.  Therefore comparing the number of Lib Cache objects (e.g. in ' -
       skip 1 -
       lef '   v$librarycache), with the number of Lib Cache Memory Objects is invalid' -
       skip 2;

column ast    format a2 trunc             heading 'ON';
column spsfe  format      9,999,999    heading 'Shared Pool|Size for|Estim (M)';
column spsf   format             99.0  heading 'SP|Size|Factr';
column elcs   format      9,999,990    heading 'Estd|Lib Cache|Size (M)';
column elcmo  format    999,999,999    heading 'Estd|Lib Cache|Mem Obj';
column elcts  format    999,999,999    heading 'Estd Lib|Cache Time|Saved (s)';
column elctsf format             99.0  heading 'Estd|LC Time|Saved|Factr';
column elcmoh format 99,999,999,999    heading 'Estd Lib Cache|Mem Obj Hits';

select shared_pool_size_for_estimate spsfe
     , shared_pool_size_factor       spsf
     , estd_lc_size                  elcs
     , estd_lc_memory_objects        elcmo
     , estd_lc_time_saved            elcts
     , estd_lc_time_saved_factor     elctsf
     , estd_lc_memory_object_hits    elcmoh
  from stats$shared_pool_advice
 where snap_id             = &end_snapid
   and dbid                = &db_id
   and instance_number     = &inst_id
 order by shared_pool_size_for_estimate;
