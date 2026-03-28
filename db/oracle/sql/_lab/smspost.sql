col rows_processed for 999,999,999,999
break on report
compute sum of rows_processed on report
 

select to_char(trunc(END_TIME,'hh'),'yyyy/mm/dd hh24:mi:ss') END_TIME,
       trunc(avg(trunc(ROWS_PROCESSED/(decode(ELAPSED_TIME,0,1,ELAPSED_TIME)/100))),2) performance,
       count(*),
       sum(ROWS_PROCESSED) ROWS_PROCESSED,
       sum(ROWS_RTX_LT) ROWS_RTX_LT,
       trunc(sum(ROWS_RTX_LT)/sum(ROWS_PROCESSED),4)*100 PERC_LT,
       sum(ROWS_RTX_ZERO) ROWS_RTX_ZERO,
       trunc(sum(ROWS_RTX_ZERO)/sum(ROWS_PROCESSED),4)*100 PERC_ZERO,
       sum(ROWS_RTX_BACKUP) ROWS_RTX_BACKUP,
       trunc(sum(ROWS_RTX_BACKUP)/sum(ROWS_PROCESSED),4)*100 PERC_BACKUP
from rlh.LOG_POST_RLH l
where STATUS = 1
  and ROWS_PROCESSED > 100000
  and trunc(end_time) = trunc(sysdate)
group by to_char(trunc(END_TIME,'hh'),'yyyy/mm/dd hh24:mi:ss')
order by end_time
/


clear break