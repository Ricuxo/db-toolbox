/*  */
CREATE OR REPLACE VIEW z$buffer_cache
   (buf_addr
   ,buf_no
   ,dba_file
   ,dba_blk
   ,tbs_id
   ,obj_id
   ,blk_class
   ,status
   ,pool
   ,dirty
   ,io_type
   ,nxt_repl
   ,prv_repl
   )
AS
SELECT
        bh.addr
       ,bh.indx
       ,bh.dbarfil
       ,bh.dbablk
       ,bh.ts#
       ,bh.obj
       ,bh.class
       ,DECODE(bh.state,0,'FREE',1,'XCUR',2,'SCUR',
                       3,'CR',4,'READ',5,'MREC',6,'IREC')
       ,bp.bp_name
       ,DECODE(BITAND(bh.flag,1),0,'N','Y')
       ,DECODE(BITAND(bh.flag,524288),0,'RANDOM','SEQUENTIAL')
       ,nxt_repl
       ,prv_repl
  FROM
        x$kcbwbpd    bp
       ,x$bh         bh
 WHERE
        bp.bp_size > 0
   AND  bh.indx >= bp.bp_lo_sid
   AND  bh.indx <= bp.bp_hi_sid
   AND  bh.inst_id = USERENV('Instance')
   AND  bp.inst_id = USERENV('Instance')
/
