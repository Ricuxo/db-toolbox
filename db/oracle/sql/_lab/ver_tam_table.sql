SELECT owner, tablespace_name, segment_name,
round(sum(bytes/1024/1024),2) as Tamanho_MB
FROM dba_segments
WHERE owner = '&owner'
AND segment_type = 'TABLE'
AND segment_name='&table'
GROUP BY owner, tablespace_name, segment_name;