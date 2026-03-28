/*  */
CREATE OR REPLACE PROCEDURE HITRATIO IS
    C_DATE DATE;
    C_HOUR NUMBER := 0;
    H_RATIO NUMBER(5,2) := 0;
    CON_GETS NUMBER := 0;
    DB_GETS NUMBER := 0;
    P_READS NUMBER := 0;
    STAT_NAME VARCHAR(64);
    temp_NAME VARCHAR(64);
    STAT_VAL NUMBER := 0;
    USERS  NUMBER := 0;
 CURSOR get_stat(p_name varchar2) IS
select
		name,
		value
	from
		v$sysstat
    	where
		name = p_name;
BEGIN
  select to_char(sysdate,'DD-MON-YY') into c_date from dual;
  select to_char(sysdate,'HH24') into c_hour from dual;
  STAT_NAME := 'db block gets';
  OPEN get_stat(stat_name);
  FETCH get_stat INTO temp_name,db_gets;
  CLOSE get_stat;
dbms_output.put_line(temp_name||':'||to_char(db_gets));
   STAT_NAME := 'consistent gets';
  OPEN get_stat(stat_name);
  FETCH get_stat INTO temp_name,con_gets;
  CLOSE get_stat;
dbms_output.put_line(temp_name||':'||to_char(con_gets));
  STAT_NAME := 'physical reads';
  OPEN get_stat(stat_name);
  FETCH get_stat INTO temp_name,p_reads;
  CLOSE get_stat;
dbms_output.put_line(temp_name||':'||to_char(p_reads));
    select count(*) into users from v$session where username is not null;
      H_RATIO := (((DB_GETS+CON_GETS-p_reads)/(DB_GETS+CON_GETS))*100);
dbms_output.put_line('hit_ratio:'||to_char(h_ratio));
    INSERT INTO  hit_ratios
      VALUES (c_date,c_hour,db_gets,con_gets,p_reads,h_ratio,0,0,users);
commit;
update hit_ratios set period_hit_ratio =
    (select round((((h2.consistent-h1.consistent)+(h2.db_block_gets-h1.db_block_gets)-
    (h2.phy_reads-h1.phy_reads))/((h2.consistent-h1.consistent)+
        (h2.db_block_gets-h1.db_block_gets)))*100,2) from hit_ratios h1, hit_ratios h2
    where h2.check_date = hit_ratios.check_date and h2.check_hour = hit_ratios.check_hour
    and ((h1.check_date = h2.check_date and h1.check_hour+1 = h2.check_hour) or
    (h1.check_date+1 = h2.check_date and h1.check_hour = '23' and h2.check_hour='0')))
where period_hit_ratio = 0;
  COMMIT;
update hit_ratios set period_USAGE =
    (select ((h2.consistent-h1.consistent)+(h2.db_block_gets-h1.db_block_gets))
    from hit_ratios h1, hit_ratios h2 where h2.check_date = hit_ratios.check_date
    and h2.check_hour = hit_ratios.check_hour  and ((h1.check_date = h2.check_date
    and h1.check_hour+1 = h2.check_hour) or (h1.check_date+1 = h2.check_date and
    h1.check_hour = '23' and h2.check_hour='0'))) where period_USAGE = 0;
  COMMIT;
EXCEPTION
    WHEN ZERO_DIVIDE THEN
    INSERT INTO  hit_ratios  VALUES (c_date,c_hour,db_gets,con_gets,p_reads,0,0,0,users);
    COMMIT;
END;
/
