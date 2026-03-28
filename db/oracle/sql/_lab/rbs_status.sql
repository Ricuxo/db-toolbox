prompt # 
prompt #  Mostra STATUS dos segmentos de ROLLBACK
prompt #  
prompt #  Se existir algum segmento com XACTS=-1,
prompt #  o segmento esta com problema e o mesmo deve ser colocado em OFFLINE
prompt #  
set lines 130
set pages 10000
column name format a13
column usn format 99999
column sta_sgm format a7
column sta_rbs format a7
column optsz(mb) format 9999g999
column HWM(mb) format 9999g999
column avact(mb) format 9999g999
column Ratio(%) format 999d99

select rn.name, rn.usn, d.status sta_sgm, rs.status sta_rbs, rs.xacts, rs.shrinks, ROUND((waits / gets) * 100, 2) "Ratio(%)", d.min_extents, 
       rs.extends, round(rs.optsize/1024/1024) "optsz(mb)", round(rs.HWMSIZE/1024/1024) "HWMSZ(mb)", round(rs.aveactive/1024/1204) "avact(mb)"
 from v$rollname rn, v$rollstat rs, dba_rollback_segs d
where rs.usn       = rn.usn 
AND   d.segment_id = rs.usn(+)
order by rn.name, rs.writes ;
