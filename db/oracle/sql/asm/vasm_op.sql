@reset 

set linesize 250

COL INST_ID FORMAT 999999999999
COL GROUP_NUMBER FORMAT 999999999999
COL OPERATION FORMAT A38
COL STATE FORMAT A29
COL POWER FORMAT 999999999999
COL ACTUAL FORMAT 999999999999
COL SOFAR FORMAT 999999999999
COL EST_WORK FORMAT 999999999999
COL EST_RATE FORMAT 999999999999
COL EST_MINUTES FORMAT 99999
COL ERROR_CODE FORMAT A44

SELECT GROUP_NUMBER
     , decode(OPERATION
				, 'REBAL', 'REBALANCE'
				, 'COD', 'Continuing Operation Directory (files)'
				, 'DSCV', 'Disk rediscovering'
				, 'RFRSH', 'Refreshing Disk to be expleed'
				, 'EXPEL', 'End of Rebal expel required'
				, OPERATION
		      ) OPERATION
     , EST_RATE
     , EST_MINUTES
     , ACTUAL
     , SOFAR
     , decode(STATE
				, 'WAIT', 'No opers running for the grp'
				, 'RUN', 'Operation running for the grp'
				, 'REAP', 'Operation is being run down'
				, 'HALT', 'Operation halted by admin'
				, 'ERRORS', 'Operation halted by errors'
				, STATE
			 ) STATE
     , POWER
     , EST_WORK
     , ERROR_CODE
  FROM V$ASM_OPERATION
/
