/*  */
column temp1_date new_value rep1_date noprint
set verify off feedback off echo off
accept start1_date prompt 'Enter Date for Friday of Week for Stats (dd-mon-yy):'
@daily_stat X &&start1_date
@logged_user_summ X &&start1_date
clear columns
undef rep1_date
column temp1_date new_value rep1_date noprint
select to_char(to_date('&&start1_date','dd-mon-yy')-1,'dd-mon-yy') temp1_date from dual;
@daily_stat X &&rep1_date
@logged_user_summ X &&rep1_date
clear columns
undef rep1_date
column temp1_date new_value rep1_date noprint
select to_char(to_date('&&start1_date','dd-mon-yy')-2,'dd-mon-yy') temp1_date from dual;
@daily_stat X &&rep1_date
@logged_user_summ X &&rep1_date
clear columns
undef rep1_date
column temp1_date new_value rep1_date noprint
select to_char(to_date('&&start1_date','dd-mon-yy')-3,'dd-mon-yy') temp1_date from dual;
@daily_stat X &&rep1_date
@logged_user_summ X &&rep1_date
clear columns
undef rep1_date
column temp1_date new_value rep1_date noprint
select to_char(to_date('&&start1_date','dd-mon-yy')-4,'dd-mon-yy') temp1_date from dual;
@daily_stat X &&rep1_date
@logged_user_summ X &&rep1_date
undef start_date
