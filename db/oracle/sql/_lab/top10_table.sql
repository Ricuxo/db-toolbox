set line 1000
select * from (
select owner, segment_name, SEGMENT_type, sum(bytes/1024/1024) MB from dba_segments
WHERE owner like nvl('&owner_name','%')
group by owner, segment_name,SEGMENT_type
order by sum(bytes/1024/1024) desc)
where rownum < 25
/

