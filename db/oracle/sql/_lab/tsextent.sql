/*
  script:   ts_extent.sql
  objetivo: segmento cujo proximo extent será maior que o espaco contiguo disponivel na tablespace
    data:     
*/

set termout on
set feedback on
set pages 1000
set lines 200

col next_extent format 9999,999
col extents     format 9999,999
col livre       format 9999,999

  select substr(a.tablespace_name,1,30) Tablespace
        ,substr(a.segment_name,1,30)    Objeto
        ,substr(a.segment_type,1,10)    Tipo
        ,a.extents                      extents
        ,(a.next_extent/1024)           next_extent
        ,(s.bytes/1024)                 Livre
    from dba_segments a
        ,(select tablespace_name 
                ,max(bytes) bytes
            from dba_free_space
        group by tablespace_name) s
   where s.tablespace_name(+) = a.tablespace_name
     and (a.next_extent) > s.bytes
order by a.tablespace_name
        ,a.segment_name
/

ttitle off

