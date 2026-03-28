column %ativas format a7
SELECT a.ATIVA, i.INATIVA, (a.ATIVA+i.INATIVA) TOTAL, round((a.ativa/(a.ATIVA+i.INATIVA))*100)||'%' "%ativas"
  FROM (select count(1) ATIVA from v$session where status='ACTIVE') a,
       (select count(1) INATIVA from v$session where status='INACTIVE') i;
