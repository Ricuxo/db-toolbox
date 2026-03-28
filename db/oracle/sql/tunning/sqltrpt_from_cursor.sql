--- 66. SQL Tuning Advisor for SQL_ID from the Cursor:

-- Oracle: 
DECLARE   
    CURSOR c_sql_stats IS
        SELECT sql_id, sql_text
        FROM v$sql     
        WHERE cursor_cache# IS NOT NULL;   
    l_sql_id VARCHAR2(30);   
    l_sql_text VARCHAR2(4000); 
BEGIN   
    OPEN c_sql_stats;   
        LOOP     
        FETCH c_sql_stats INTO l_sql_id, l_sql_text;     
        EXIT WHEN c_sql_stats%NOTFOUND;      
        
        DBMS_OUTPUT.PUT_LINE('Analyzing SQL_ID: ' || l_sql_id);      
        
        -- Call the SQL Tuning Advisor     
        
        DBMS_SQLTUNE.ADVISE(       
            sql_id => l_sql_id,       
            tuning_set => 'OPTIMIZATION_SET',  -- Adjust set as needed       
            tuning_task_name => 'tuning_' || l_sql_id     
        );  
        END LOOP;   
    CLOSE c_sql_stats; 
END; 
/ 


