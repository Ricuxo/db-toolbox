/*  */
@title80 'Fragmentation Index'
spool rep_out\&db\frag_index
select  
 segment_type,
 count(*) num_types,
 trunc(EXTENTS/50) "Extents*50"
FROM    DBA_SEGMENTS
group by segment_type, trunc(extents/50)
order by segment_type, trunc(extents/50),count(*)
/
spool off
