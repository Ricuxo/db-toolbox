/*  */
break on class
select class,	name,	value from v$sysstat
where value <> 0
order by class,value
