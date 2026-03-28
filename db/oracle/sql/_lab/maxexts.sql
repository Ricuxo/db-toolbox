rem Script para verificar se nao ultrapassara o maximo de extents
rem
promp Alert - segmentos que nao aumentarao extents - alterar max_extents:
col owner format a15;
col segment_name format a35;
col segment_type format a10;
select owner,segment_name,segment_type,max_extents,extents
 from dba_segments 
 where extents + 1 >= max_extents
     and segment_type not in ('CACHE')
/
promp Segmentos cujo max_extents esta proximo do limite:
col owner format a15;
col segment_name format a35;
col segment_type format a10;
select owner,segment_name,segment_type,max_extents,extents
 from dba_segments 
 where extents + 5 >= max_extents
     and segment_type not in ('CACHE')
/
