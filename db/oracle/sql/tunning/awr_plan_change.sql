/* Verifica desempenho da função ao longo do tempo 
Exemplo de saida:
   SNAP_ID   NODE BEGIN_INTERVAL_TIME            SQL_ID        PLAN_HASH_VALUE        EXECS    AVG_ETIME        AVG_LIO
---------- ------ ------------------------------ ------------- --------------- ------------ ------------ --------------
      3206      1 02-OCT-08 08.00.38.743 AM      0qa98gcnnza7h       568322376            4       10.359      121,722.8
      3235      1 03-OCT-08 01.00.44.932 PM      0qa98gcnnza7h                            1       10.865      162,375.0
      3235      1 03-OCT-08 01.00.44.932 PM      0qa98gcnnza7h      3723858078            1      127.664   28,913,271.0
      3236      1 03-OCT-08 01.28.09.000 PM      0qa98gcnnza7h       568322376            1        7.924      162,585.0
      3236      1 03-OCT-08 01.28.09.000 PM      0qa98gcnnza7h      3723858078            1       86.682   27,751,123.0
      3305      1 06-OCT-08 10.00.11.988 AM      0qa98gcnnza7h                            4       64.138   22,616,931.5
      3305      1 06-OCT-08 10.00.11.988 AM      0qa98gcnnza7h       568322376            2        5.710       81,149.0
      3306      1 06-OCT-08 11.00.16.490 AM      0qa98gcnnza7h                            6        5.512      108,198.5
      3307      1 06-OCT-08 12.00.20.716 PM      0qa98gcnnza7h                            2        3.824       81,149.0
      3328      1 07-OCT-08 08.39.20.525 AM      0qa98gcnnza7h                           30       35.473      156,904.7
      3335      1 07-OCT-08 03.00.20.950 PM      0qa98gcnnza7h      3723858078           10      455.862   28,902,128.6

A saida não é exatamente assim, mas é bem parecida.
*/

set lines 155
col execs for 999,999,999
col avg_etime for 999,999.999
col avg_lio for 999,999,999.9
col begin_interval_time for a30
col node for 99999
break on plan_hash_value on startup_time skip 1
select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
nvl(executions_delta,0) execs,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio,
(disk_reads_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_pio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where sql_id = 'c126hvqhqpbd3'
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
order by 1, 2, 3
/

