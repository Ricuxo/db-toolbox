/*  */
@title80 'Sort Segment List'
spool rep_out\&db\sort_segments
select segrfno# File_no,segfile# sort_seg,sum(extents) extents, (sum(blocks)*8192)/(1024*1024) meg
from v$sort_usage group by segrfno#,segfile#
/
spool off

