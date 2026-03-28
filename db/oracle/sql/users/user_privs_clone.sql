Informe o valor para new_user: BRRZB
Informe o valor para cur_user: BRRZB
create user BRRZB identified by values ''  default tablespace TBSRMSDD1M01 temporary tablespace TEMP
01 profile CEABR;                                                                                   
                                                                                                    
grant CADASTRO_OPER_1 to BRRZB;                                                                     
grant COMPRAS_VIEW_3 to BRRZB;                                                                      
grant ADMSEL_RMS to BRRZB;                                                                          
grant ADMIUDE_RMS to BRRZB;                                                                         
grant COMPRAS_EDIT to BRRZB;                                                                        
grant CREATE VIEW to BRRZB;                                                                         
grant CREATE SYNONYM to BRRZB;                                                                      
grant CREATE SESSION to BRRZB;                                                                      
alter user BRRZB default role                                                                       
CADASTRO_OPER_1,
COMPRAS_VIEW_3,
ADMSEL_RMS,
ADMIUDE_RMS,
COMPRAS_EDIT;                             
