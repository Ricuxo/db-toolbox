/*  */
create or replace procedure tdms(                                               
	psSwitchTypeNm	IN	VARCHAR2,                                             
	psOfficeNm 		IN	VARCHAR2,                                             
	psDate 			IN	VARCHAR2,                                             
	psTime 			IN	VARCHAR2,                                             
	psTrunkGroupNm 	IN         VARCHAR2,                                             
	psRoutingCd 		IN	VARCHAR2,                                             
	pnIncomingPegQty 	IN	NUMBER,                                               
	pnOutgoingPegQty 	IN 	NUMBER,                                               
	pnOverflowPegQty 	IN 	NUMBER,                                               
	pnOverflowPct 		IN	NUMBER,                                               
	pnCircuitsInServiceQty 	IN	NUMBER,                                               
	pnTrunkGroupNo 	IN	NUMBER,                                               
	pnCallDurationSecQty 	IN	NUMBER,                                               
	pnUsage		IN	NUMBER,                                               
	pnBusyCircuitQty	IN	NUMBER,                                               
	pnRecordNo		IN	NUMBER)                                               
AS                                                                              
lsDateTime      		CHAR(14);                                                       
lsCurrentRecord 	VARCHAR2(1700);                                                 
lnSqlErrorCd    		NUMBER;                                                         
lsSqlErrorMsg   		VARCHAR2(500);                                                  
lnRecordCnt     		NUMBER;                                                         

BEGIN                                
	lsDateTime := psDate || ' '  || psTime;
BEGIN
	INSERT INTO office                                                              
		( office_nm, responsibility_cd )                                                
	VALUES
		( psOfficeNm, NULL )
	;
EXCEPTION             
	WHEN dup_val_on_index THEN
	null;                                                          
END;
BEGIN
	INSERT INTO trunk_group                                                         
		( office_nm, trunk_group_nm, trunk_group_no )                                   
	VALUES 
		( psOfficeNm, psTrunkGroupNm, pnTrunkGroupNo )
	;                          
EXCEPTION             
	WHEN dup_val_on_index THEN
	null;                                                          
END;
BEGIN
	INSERT INTO    measurement                                                      
		(office_nm, trunk_group_nm, report_dttm, routing_cd, incoming_peg_qty,          
		outgoing_peg_qty, overflow_peg_qty, overflow_pct,                               
		circuits_in_service_qty, call_duration_sec_qty, usage,                          
		busy_circuit_qty, switch_type_nm, record_no)                                    
	VALUES
		(psOfficeNm, psTrunkGroupNm, TO_DATE(lsDateTime, 'MM/DD/YY HH24:MI'),     
		NVL(psRoutingCd, NULL), NVL(pnIncomingPegQty, NULL),                            
		NVL(pnOutgoingPegQty, NULL), NVL(pnOverflowPegQty, NULL),                       
		NVL(pnOverflowPct, NULL), NVL(pnCircuitsInServiceQty, NULL),                    
		NVL(pnCallDurationSecQty, NULL), NVL(pnUsage, NULL),                            
		NVL(pnBusyCircuitQty, NULL), NVL(psSwitchTypeNm, NULL), pnRecordNo)
	;
EXCEPTION             
	WHEN dup_val_on_index THEN
	/*BEGIN
	lsCurrentRecord := 'TDMS=' || psSwitchTypeNm || ' ENTITY=' || psOfficeNm ||
 	' DATE=' || psDate || ' TIME=' || psTime || ' GROUP=' || psTrunkGroupNm || ' RC=' || 
	psRoutingCd ||' IPC=' || pnIncomingPegQty || ' OPC=' || pnOutgoingPegQty || 
	' OFL=' || pnOverflowPegQty || ' %OFL=' ||pnOverflowPct || ' NCI=' ||
	pnCircuitsInServiceQty || ' TRK_GRP_NO=' || pnTrunkGroupNo || ' HT=' ||
	pnCallDurationSecQty || ' USG=' || pnUsage || ' NMB=' || pnBusyCircuitQty;
	lnSqlErrorCd := SQLCODE;                                                        
	lsSqlErrorMsg := SQLERRM(lnSqlErrorCd);                                         
	INSERT INTO error_log                                                           
		(error_dttm, error_cd, error_message_txt, line_item_txt)                        
	VALUES 
		(sysdate, lnSqlErrorCd, lsSqlErrorMsg, lsCurrentRecord);
	END;*/
null;                                                   
END;                                                                            
COMMIT;
EXCEPTION                                                                         
	WHEN others THEN              
	lsCurrentRecord := 'TDMS=' || psSwitchTypeNm || ' ENTITY=' || psOfficeNm ||
 	' DATE=' || psDate || ' TIME=' || psTime || ' GROUP=' || psTrunkGroupNm || ' RC=' || 
	psRoutingCd ||' IPC=' || pnIncomingPegQty || ' OPC=' || pnOutgoingPegQty || 
	' OFL=' || pnOverflowPegQty || ' %OFL=' ||pnOverflowPct || ' NCI=' ||
	pnCircuitsInServiceQty || ' TRK_GRP_NO=' || pnTrunkGroupNo || ' HT=' ||
	pnCallDurationSecQty || ' USG=' || pnUsage || ' NMB=' || pnBusyCircuitQty;
	lnSqlErrorCd := SQLCODE;                                                        
	lsSqlErrorMsg := SQLERRM(lnSqlErrorCd);                                         
	INSERT INTO error_log                                                           
		(error_dttm, error_cd, error_message_txt, line_item_txt)                        
	VALUES 
		(sysdate, lnSqlErrorCd, lsSqlErrorMsg, lsCurrentRecord);                 
END;                                                                            
/                                                                               
