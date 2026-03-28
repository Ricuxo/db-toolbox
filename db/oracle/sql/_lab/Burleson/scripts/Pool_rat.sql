/*  */
rem Report on the ratios of unique hash values and
rem unique address values to all values for SQL areas
rem
column u_hash_ratio format 999.999 heading "Unique Hash Ratio"
column u_address_ratio format 999.999 heading "Unique Address Ratio"
start title80 "Unique Hash an Address Ratios"
spool rep_out\&&db\u_hash_addr_rat.lst
select (count(distinct(hash_value))/count(hash_value))*100 u_hash_ratio,
	(count(distinct(address))/count(address))*100 u_address_ratio from v$sqlarea
/
spool off

