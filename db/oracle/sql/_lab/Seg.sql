prompt # 
prompt # Retorna informacoes sobre o segmento (tabela, indice, lob e etc)
prompt # 
prompt # 
undef segment_name
column segment_name format a30
column segment_type format a10
column tablespace_name format a20
column pctused format a10
select * from (select s.segment_name, s.segment_type, s.tablespace_name, t.pct_free as "pctfree", to_char(t.pct_used) as "pctused", s.blocks, s.bytes, s.extents, s.initial_extent, s.next_extent
                 from dba_segments s, dba_tables t 
                where s.segment_name = t.table_name
                and   t.table_name   = upper('&&segment_name')
               union all
               select i.index_name, i.index_type, i.tablespace_name, i.pct_free as "pctfree", null as "pctused", s.blocks, s.bytes, s.extents, s.initial_extent, s.next_extent
                 from dba_segments s, dba_indexes i
                where (s.segment_name = i.index_name 
                and   (i.table_name = upper('&&segment_name') or 
                       i.index_name = upper('&&segment_name')
                      ))
                ) b
order by 2 desc
/
