	set lines 160
	col NAME for a14
	col value for a15
	SELECT name, value, datum_time, time_computed FROM V$DATAGUARD_STATS  WHERE name like 'apply lag';