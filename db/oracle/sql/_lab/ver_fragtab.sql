SET PAGES 50000 LINES 32767
col owner for a20
col "TOTAL_SIZE" for a20
col "ACTUAL SIZE" for a20
select owner,table_name,blocks,num_rows,avg_row_len,round(((blocks*8/1024)),2)||'MB' "TOTAL_SIZE",
    round((num_rows*avg_row_len/1024/1024),2)||'Mb' "ACTUAL_SIZE",
    round(((blocks*8/1024)-(num_rows*avg_row_len/1024/1024)),2) ||'MB' "FRAGMENTED_SPACE"
    from dba_tables  WHERE Owner NOT IN (
       'SYS', 'OUTLN', 'SYSTEM', 'CTXSYS', 'DBSNMP',
       'LOGSTDBY_ADMINISTRATOR', 'ORDSYS',
       'ORDPLUGINS', 'OEM_MONITOR', 'WKSYS', 'WKPROXY',
       'WK_TEST', 'WKUSER', 'MDSYS', 'LBACSYS', 'DMSYS',
       'WMSYS', 'OLAPDBA', 'OLAPSVR', 'OLAP_USER',
       'OLAPSYS', 'EXFSYS', 'SYSMAN', 'MDDATA',
       'SI_INFORMTN_SCHEMA', 'XDB', 'ODM')
	AND TABLE_NAME='&Nome_Tabela'
	   order by "FRAGMENTED_SPACE" asc;