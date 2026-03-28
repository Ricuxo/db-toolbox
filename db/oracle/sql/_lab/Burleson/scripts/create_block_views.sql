/*  */
drop view block_status;
CREATE VIEW BLOCK_STATUS AS
     SELECT DECODE(state, 0, 'FREE',
            1, DECODE(lrba_seq,0, 'AVAILABLE', 'BEING USED'),
            3, 'BEING USED', state) "BLOCK STATUS", 
            COUNT(*) "COUNT" 
      FROM x$bh
      GROUP BY  
      decode(state,0,'FREE',1,decode(lrba_seq,0,'AVAILABLE',     
          'BEING USED'),3,'BEING USED',state)
/
grant select on block_status to dbautil;
drop view buffer_status;
create view buffer_status as 
select decode(greatest(class,10),10,decode(class,1,'Data',2,'Sort',4,'Header',
   to_char(class)),'Rollback') "Class",
   sum(decode(bitand(flag,1),1,0,1)) "Not Dirty",
   sum(decode(bitand(flag,1),1,1,0)) "Dirty",
   sum(dirty_queue) "On Dirty",count(*) "Total"
  from x$bh
  group by decode(greatest(class,10),10,decode(class,1,'Data',
                                          2,'Sort',
                                          4,'Header',
                                          to_char(class)),'Rollback')
/
grant select on buffer_status to dbautil;
