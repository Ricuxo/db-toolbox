set lines 999
set pages 1000
col tablespace_name format a25
col total_livre     format 999,999,990.00
col maior_livre     format 999,999,990.00
col tamanho         format 999,999,990.00
col total_usado     format 999,999,990.00
col used          format         990.00
compute sum of tamanho     on report
compute sum of total_usado on report
break on report

select c.con_id, c.name  con_name, t.tablespace_name, t.contents, t.status
from v$containers c, cdb_tablespaces t
where c.con_id=t.con_id
order by 1,2
/
select 
	* 
from
	(
	select
		b.tablespace_name,
		b.mb                        			as tamanho,
		sum(a.bytes)/1024/1024      			as total_livre,
		max(a.bytes)/1024/1024      			as maior_livre,		
		100-((sum(a.bytes)/1024/1024)/(b.mb)*100) 	as used,
		b.mb-sum(a.bytes)/1024/1024			as total_usado,		
		count(b.tablespace_name)    			as qtd
	from 
		(
		select
			tablespace_name,
			sum(bytes)/1024/1024 mb
		from
			dba_data_files
		group by
			tablespace_name
		) b,
		dba_free_space a
	where
		b.tablespace_name  = a.tablespace_name (+)
	group by
		b.tablespace_name,
		b.mb
	union all
	select
		tablespace_name,
		tamanho,
		maior_livre,
		total_livre,
	        decode(total_livre,0,1,total_livre)/(total_usado*100) as "% Livre",
		total_usado,
		qtd
	from
		(
		select
			tf.tablespace_name,
			sum(tf.bytes_used)/1024/1024 as tamanho,
			0			     as maior_livre,
			sum(tf.bytes_free)/1024/1024 as total_livre,
			sum(tf.bytes_used)/1024/1024 as total_usado,
			count(tf.tablespace_name)    as qtd
		from
			v$temp_space_header tf
		group by
			tf.tablespace_name  
		)
	)
order by 
	used desc
/
