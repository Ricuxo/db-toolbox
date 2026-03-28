col FILE_NAME for a70
SELECT * FROM
(
SELECT a.file#,                                    
       b.file_name,                                
       a.singleblkrds,                             
       a.singleblkrdtim,                           
       a.singleblkrdtim/a.singleblkrds average_wait
FROM   v$filestat a, dba_data_files b              
WHERE  a.file# = b.file_id                         
AND    a.singleblkrds > 0                          
ORDER BY average_wait DESC
) 
WHERE rownum < 11       

/
