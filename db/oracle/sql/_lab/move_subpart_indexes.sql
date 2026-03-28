SET SERVEROUTPUT ON
SET verify OFF
SET feed OFF
SET termout ON

SPOOL C:\TEMP\MOVE_SUBPART.SQL 

DECLARE
	V_SUBPART				VARCHAR2(100);
	V_TABLE_OWNER			VARCHAR2(100);
	V_TABLE_NAME			VARCHAR2(100);
	V_PARTNAME				VARCHAR2(100);
	V_INDEX_NAME			VARCHAR2(100);
	V_INDEX_OWNER			VARCHAR2(100);
	V_CMD_SUBPART			VARCHAR2(200);
	V_CMD_IDX				VARCHAR2(200);
	CUR_INDEX				SYS_REFCURSOR;
	CUR_SUBPART				SYS_REFCURSOR;
BEGIN
	OPEN CUR_SUBPART FOR SELECT TABLE_OWNER, TABLE_NAME, PARTITION_NAME, SUBPARTITION_NAME FROM DBA_TAB_SUBPARTITIONS
						WHERE   TABLE_OWNER='SGEMS002'
							AND TABLE_NAME='USAGE_EVENT'
							AND TABLESPACE_NAME IN ('GEMS_DATA_128M','GEMS_DATA_4M','GEMS_DATA_01')
							AND PARTITION_NAME IN (	'SYS_P1729115'
													,'SYS_P2288230'
													,'SYS_P1736277'
													,'SYS_P1729015'
													,'SYS_P1718950'
													,'SYS_P1719131'
													,'SYS_P1718224'
													,'SYS_P1718133'
													,'SYS_P1718677'
													,'SYS_P1737376'
													,'SYS_P1738355'
													,'SYS_P2286015'
													,'SYS_P2288725'
													,'SYS_P1715940'
													,'SYS_P1736186'
													,'SYS_P1716031'
													,'SYS_P2404615'
													,'SYS_P2404158'
													,'SYS_P2289657'
													,'SYS_P2404066'
													,'SYS_P1735121'
													,'SYS_P2394286'
													,'SYS_P2403974'
													,'SYS_P1727235'
													,'SYS_P1717405'
													,'SYS_P2289566'
													,'SYS_P1726535'
													,'SYS_P2391135'
													,'SYS_P1725755'
													,'SYS_P2404706'
													,'SYS_P2394468'
													,'SYS_P1725557'
													,'SYS_P2397850'
													,'SYS_P2404524'
													,'SYS_P2397371'
													,'SYS_P2396711'
													,'SYS_P1733651'
													,'SYS_P2288816'
													,'SYS_P1736186'
													,'SYS_P1735597'
													,'SYS_P2397084'
													,'SYS_P2405071'
													,'SYS_P2398830'
													,'SYS_P2398143'
													,'SYS_P2403882'
													,'SYS_P1728915'
													,'SYS_P1732515'
													,'SYS_P1730115'
													,'SYS_P2393922'
													,'SYS_P2289566'
													,'SYS_P2392115'
													,'SYS_P2398630'
													,'SYS_P2397471'
													,'SYS_P2397942'
													,'SYS_P2404889'
													,'SYS_P2394559'
													,'SYS_P2404341'
													,'SYS_P2390465'
													,'SYS_P2397176'
													,'SYS_P1733560'
													,'SYS_P1731315'
													,'SYS_P2397850'
													,'SYS_P1734015'
													,'SYS_P2396902'
													,'SYS_P2402553'
													,'SYS_P1734197'
													,'SYS_P1733106'
													,'SYS_P1729915'
													,'SYS_P2286015'
													,'SYS_P1734475'
													,'SYS_P2289475'
													,'SYS_P2393077'
													,'SYS_P2394195'
													,'SYS_P2394195'
													,'SYS_P2403051'
													,'SYS_P2391135'
													,'SYS_P2391335'
													,'SYS_P2403790'
													,'SYS_P2394013'
													,'SYS_P2287886'
													,'SYS_P2289006'
													,'SYS_P1735597'
													,'SYS_P2395381'
													,'SYS_P2286298'
													,'SYS_P2396993'
													,'SYS_P2286755'
													,'SYS_P2289370'
													,'SYS_P2393830'
													,'SYS_P2404158'
													,'SYS_P2404432'
													,'SYS_P2394924'
													,'SYS_P2396993'
													,'SYS_P2393639'
													,'SYS_P2403974'
													,'SYS_P2287135'
													,'SYS_P2400890'
													,'SYS_P2403424'
													,'SYS_P2400690'
													,'SYS_P2395016'
													,'SYS_P2392595'
													,'SYS_P2404706'
													,'SYS_P2396524'
													,'SYS_P2390855'
													,'SYS_P2390556'
													,'SYS_P2398830'
													,'SYS_P2398432'
													,'SYS_P1735506'
													,'SYS_P2405346'
													,'SYS_P2287698'
													,'SYS_P2405255'
													,'SYS_P2392895'
													,'SYS_P2403607'
													,'SYS_P2396432'
													,'SYS_P2393739'
													,'SYS_P2398530'
													,'SYS_P2404889'
													,'SYS_P2395110'
													,'SYS_P2401882'
													,'SYS_P2393547'
													,'SYS_P2401590'
													,'SYS_P2396150'
													,'SYS_P2394742'
													,'SYS_P2403051'
													,'SYS_P2399411'
													,'SYS_P2401290'
													,'SYS_P2401190'
													,'SYS_P2395770'
													,'SYS_P2403882'
													,'SYS_P2395582'
													,'SYS_P2401490'
													,'SYS_P2400990'
													,'SYS_P2400290'
													,'SYS_P2396250'
													,'SYS_P2395861'
													,'SYS_P2403790'
													,'SYS_P2394833'
													,'SYS_P2398930'
													,'SYS_P2396341'
													,'SYS_P2400481'
													,'SYS_P2401590'
													,'SYS_P2403607'
													,'SYS_P2403516'
													,'SYS_P2399603'
													,'SYS_P2399021'
													,'SYS_P2400390'
													,'SYS_P2400990'
													,'SYS_P2396341'
													,'SYS_P2403150'
													,'SYS_P2403150'
													,'SYS_P2399021'
													,'SYS_P2400390'
													,'SYS_P2401790'
													,'SYS_P2399694'
													,'SYS_P2399694'
													,'BEFORE_2013') ORDER BY PARTITION_NAME;
	LOOP
		FETCH CUR_SUBPART INTO V_TABLE_OWNER, V_TABLE_NAME, V_PARTNAME, V_SUBPART;
		EXIT WHEN CUR_SUBPART%NOTFOUND;
		/* Se for executar vi spool */
		V_CMD_SUBPART := 'ALTER TABLE '||V_TABLE_OWNER||'.'||V_TABLE_NAME||' MOVE SUBPARTITION '||V_SUBPART||' TABLESPACE GEMS_DATA_02 PARALLEL 8;';
		/* Se for executar com immediate */
		--V_CMD_SUBPART := 'ALTER TABLE '||V_TABLE_OWNER||'.'||V_TABLE_NAME||' MOVE SUBPARTITION '||V_SUBPART||' TABLESPACE GEMS_DATA_02 PARALLEL 8';
		DBMS_OUTPUT.PUT_LINE(V_CMD_SUBPART);
		--EXECUTE IMMDIATE V_CMD_SUBPART;
		OPEN CUR_INDEX FOR SELECT INDEX_OWNER, INDEX_NAME, SUBPARTITION_NAME FROM DBA_IND_SUBPARTITIONS 
		                   WHERE INDEX_OWNER=V_TABLE_OWNER 
						   AND INDEX_NAME = 'PK_USAGE_EVENT' 
						   AND PARTITION_NAME=V_PARTNAME 
						   AND SUBPARTITION_NAME=V_SUBPART;
		LOOP
			FETCH CUR_INDEX INTO V_INDEX_OWNER, V_INDEX_NAME, V_SUBPART;
			EXIT WHEN CUR_INDEX%NOTFOUND;
			/* Se for executar via spool */
			V_CMD_IDX := 'ALTER INDEX '||V_INDEX_OWNER||'.'||V_INDEX_NAME||' REBUILD SUBPARTITION '||V_SUBPART||' TABLESPACE GEMS_DATA_02 PARALLEL 8;';
			/* Se for executar com immediate */
			--V_CMD_IDX := 'ALTER INDEX '||V_INDEX_OWNER||'.'||V_INDEX_NAME||' REBUILD SUBPARTITION '||V_SUBPART||' TABLESPACE GEMS_DATA_02 PARALLEL 8';
			DBMS_OUTPUT.PUT_LINE(V_CMD_IDX);
			--EXECUTE IMMEDIATE V_CMD_INDEX;
		END LOOP;
	END LOOP;
EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

SPOOL OFF;