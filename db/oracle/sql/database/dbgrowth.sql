clear columns
set verify off
col tot_mon noprint new_value range
set lines 500
col MONTH for a30
-- Compute how many months have gone since the database was created
select ceil(months_between(sysdate, created)) tot_mon
from v$database
/
col maxinc noprint new_value max_inc
-- Compute the maximum number of times a file created in 'autoextend' mode
-- has grown
select max(round((d.bytes - d.create_bytes) / f.inc / d.block_size)) maxinc
from sys.file$ f,
     v$datafile d
where f.inc > 0
  and f.file# = d.file#
  and d.bytes > d.create_bytes
/
col GB format 9999990.00
col volume format A60
with extended_files as
            (select file#,
                    nvl(lag(file_size, 1) over (partition by file#
                                                order by file_size), 0)
prior_size,
                    file_size,
                    block_size
             from (select f.file#,
                          f.create_blocks + x.rn * f.inc file_size,
                          f.block_size    
                   from (select f.file#,
                                d.create_bytes / d.block_size create_blocks,
                                f.inc,
                                d.bytes / d.block_size blocks,
                                d.block_size
                         from sys.file$ f,
                              v$datafile d   
                         where f.inc > 0
                           and f.file# = d.file#
                           and d.bytes > d.create_bytes
                           and rownum > 0) f,
                        (select rownum - 1 rn
                         from dual
                         connect by level <= &max_inc + 1) x
                   where (f.create_blocks + x.rn * f.inc) <= f.blocks))
select "MONTH",
       round(cumul/1024, 2) GB,
       -- Draw a histogram
       rpad('=', round(60 * cumul / current_M), '=') volume
from
(select to_char(cal.mon, 'MON-YYYY') "MONTH",
             sum(nvl(evt.M, 0)) over (order by cal.mon range unbounded
preceding) cumul,
             tot.curr_M current_M,
             cal.mon
      from -- current database size (data size)
           (select round(sum(bytes)/1024/1024) curr_M
            from v$datafile) tot,
           -- all the months since the database was created
           (select add_months(trunc(sysdate, 'MONTH'), -rn) mon
            from (select rownum - 1 rn
                  from dual
                  connect by level <= &range)) cal,
           -- all the months when the size of the database changed
           (select size_date,
                   round(sum(bytes)/1024/1024) M
            from (-- files in autoextend mode
                  select file#, max(bytes) bytes, size_date
                  from (select file#, bytes, trunc(min(ctime), 'MONTH')
size_date
                        -- Get the oldest creation date of tables or indexes
                        -- that are located in extensions.
                        -- Other segment types are ignored.
                        from (select s.file#,
                                     f.file_size * f.block_size bytes,
                                     o.ctime
                              from sys.seg$ s,
                                   extended_files f,
                                   sys.tab$ t,
                                   sys.obj$ o
                              where s.file# = f.file#
                                and s.type# = 5
                                and s.block# between f.prior_size and
f.file_size
                                and s.file# = t.file#
                                and s.block# = t.block#
                                and t.obj# = o.obj#
                              union all
                              select s.file#,
                                     f.file_size * f.block_size bytes,
                                     o.ctime
                              from sys.seg$ s,
                                   extended_files f,
                                   sys.ind$ i,
                                   sys.obj$ o
                              where s.file# = f.file#
                                and s.type# = 6
                                and s.block# between f.prior_size and
f.file_size
                                and s.file# = i.file#
                                and s.block# = i.block#
                                and i.obj# = o.obj#)
                        group by file#, bytes)
                  group by file#, size_date
                  union all
                  -- files that are not in autoextend mode
                  select d.file#,
                         d.create_bytes bytes,
                         trunc(d.creation_time, 'MONTH') size_date
                  from v$datafile d,
                       sys.file$ f
                  where nvl(f.inc, 0) = 0
                    and f.file# = d.file#)
            group by size_date) evt
      where evt.size_date (+) = cal.mon)
order by mon
/