/*  */
create view new_dba_free_space (segment_file#,seg_block#,extent#,file#,block#,length) as
select segfile#, 
segblock#, 
ext#, 
file#, 
block#, 
length 
from uet$ 
union all 
select ktfbuesegfno, 
ktfbuesegbno, 
ktfbueextno, 
ktfbuefno, 
ktfbuebno, 
ktfbueblks 
from sys.x$ktfbue
/


