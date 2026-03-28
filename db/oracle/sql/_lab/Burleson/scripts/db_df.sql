/*  */
create or replace view dba_file_data as
select
 a.name tablespace,a.dflminext min_extents, a.dflmaxext max_extents,
 a.dflinit init,a.dflincr next,a.dflextpct pct_increase, d.name 
 datafile,
 b.blocks datafile_size, c.maxextend max_extend, c.inc ext_incr
 from sys.ts$ a, sys.file$ b, sys.filext$ c, v$dbfile d
 where
 a.ts#=b.ts# and 
 b.file#=c.file#(+) and 
 b.file#=d.file#(+)
 /
