column value format 999g999g999g999g999g999
column dt_coleta format a14
column tpEvento format a18
column st# format 999
set lines 150 pages 50000
SELECT to_char(c.dt_COLETA,'RR/MM/DD HH24:MI') dt_COLETA,
       round((c.value -  lag(c.value) over (partition by c.name
                                            order by c.name, c.dt_COLETA)
       )) value,
       decode(c.class, 1, 'User'
                     , 2, 'Redo'
                     , 4, 'Enqueue'
                     , 8, 'Cache'
                     , 16, 'OS'
                     , 32, 'Parallel Server'
                     , 64, 'SQL'
                     , 128, 'Debug', c.class) tpEvento,
       c.name, STATISTIC# st#
  from syscpd.monitor_sysstat c
 where c.STATISTIC# in  (2, 4, 6, 7, 8, 9, 12,15, 20, 41, 42, 87,161,164,176,230,235,238) 
 and   dt_coleta between nvl(to_date('&inicio_ddmmyyyy_hh24mi', 'ddmmyyyy hh24mi'), trunc(to_date('01'||to_char(sysdate, 'mmyyyy'), 'ddmmyyyy')))
                     and nvl(to_date('&fim_ddmmyyyy_hh24mi', 'ddmmyyyy hh24mi'), last_day(sysdate))
order by c.name, to_char(c.dt_COLETA,'RR/MM/DD HH24:MI');
