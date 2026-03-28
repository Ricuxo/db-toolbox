/*Com as informações que são armazenadas no AWR tem como facilmente calcularmos
 a quantidade de transações por sergundo (TPS) que acontecem em um banco de dados Oracle.
 O exemplo abaixo ilustra isso para os últimos 7 dias:
 */
select min(begin_time), max(end_time),
sum(case metric_name when 'User Commits Per Sec' then average end) User_Commits_Per_Sec,
sum(case metric_name when 'User Rollbacks Per Sec' then average end) User_Rollbacks_Per_Sec,
sum(case metric_name when 'User Transaction Per Sec' then average end) User_Transactions_Per_Sec,
snap_id
from dba_hist_sysmetric_summary
where trunc(begin_time) > sysdate-7
group by snap_id
order by snap_id;

