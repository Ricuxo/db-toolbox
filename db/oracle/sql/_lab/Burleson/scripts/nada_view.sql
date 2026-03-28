/*  */
drop table test;
create table test
( COUNT_OF_HITS                            NUMBER,
 STATE                                    CHAR(2),
 ACCESS_DATE                              DATE,
 SUM_TYPE                                 CHAR(3))
storage(initial 1m next 1m pctincrease 0);

drop table test2;
create table test2
( DISTINCT_HITS                            NUMBER,
 TOTAL_HITS                               NUMBER,
 ACCESS_DATE                              DATE,
 TOTAL_TYPE                               CHAR(3))
storage (initial 500k next 500k pctincrease 0);

rem Code for view: SUMMARIZE_INTERACTIONS
CREATE OR REPLACE VIEW SUMMARIZE_INTERACTIONS as
select docid,trunc(creation_ts) action_date from dbo.bbs_interaction_log;

create or replace view nada as
select 
decode(sum_type,'CD ','CNET Distinct',
                'CT ','CNET Total',
                'WD ','Web Distinct',
                'WT ','Web Total',
                'NDD','Web Distinct Daily',
                'NTD','Net Total Daily',
                'NDM','Net Distinct Monthly',
                'NTM','Net Total Monthly',
                'NSD','Net Summary Daily',
                'NSM','Net Summary Monthly',
                'WSM','Web Distinct Monthly',
                'CSD','CNET Distinct Daily',
                'WSD','Web Summary Daily',
                'CSM','CNET Distinct Monthly',
                sum_type) name,
 COUNT_OF_HITS value,  
 STATE total_hits, 
 ACCESS_DATE check_date from test
union
select
decode(total_type,'CD ','CNET Distinct',
                'CT ','CNET Total',
                'WD ','Web Distinct',
                'WT ','Web Total',
                'NDD','Web Distinct Daily',
                'NTD','Net Total Daily',
                'NDM','Net Distinct Monthly',
                'NTM','Net Total Monthly',
                'NSD','Net Summary Daily',
                'NSM','Net Summary Monthly',
                'WSM','Web Distinct Monthly',
                'CSD','CNET Distinct Daily',
                'WSD','Web Summary Daily',
                'CSM','CNET Distinct Monthly',
                total_type) name,
 DISTINCT_HITS value, 
 to_char(TOTAL_HITS) total_hits, 
 ACCESS_DATE check_date from test2
union
select 
  'INTERACTIONS(total)' name,
  count(*) value, 
  '  ' total_hits,
  action_date check_date from summarize_interactions
group by action_date
union
select 
  'CONTACTS(total)' name,
  count(*) value,
  '  ' total_hits, 
  trunc(creation_ts) check_date from dbo.users
where site_id>1
group by trunc(creation_ts)
/
