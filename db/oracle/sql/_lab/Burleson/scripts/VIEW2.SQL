/*  */
rem
rem Name:     view2.sql
rem
rem FUNCTION: Create free_space view for use by freespc reports
rem
rem exit
create view free_space2
	    (tablespace, file_id, pieces, free_bytes, free_blocks, 
	     largest_bytes,largest_blks,fsfi) as
select tablespace_name, file_id, count(*),
    sum(bytes), sum(blocks),
    max(bytes), max(blocks),
    sqrt(max(blocks)/sum(blocks))*(100/sqrt(sqrt(count(blocks))))
 from sys.dba_free_space
group by tablespace_name, file_id;
