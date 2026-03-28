/*  */
rem Code for view: SORTERS                                                    
CREATE OR REPLACE VIEW sorters as                                       
select SYSDATE system_date                                                                 
, s.sid                                                                        
, s.username                                                                   
, b.extents                                                                    
, b.blocks                                                                     
, c.sql_text                                                                   
from v$session s                                                               
, v$sort_usage b                                                               
, v$sqlarea c                                                                  
where s.saddr = b.session_addr                                                 
and s.sql_address = c.address;
                                              
                                                                               
