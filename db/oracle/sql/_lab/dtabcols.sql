COL DATA_TYPE    FORMAT A29
COL DLENGTH      FORMAT A7
COL CHAR_USED    FORMAT A9
COL NULLABLE     FORMAT A8

SET LONG 500

SELECT COLUMN_ID
     , COLUMN_NAME
     , DATA_TYPE
/*
     , '('||case when DATA_SCALE is null
                 then case when DATA_PRECISION is null
		                   then DATA_LENGTH||')'
		                   else DATA_PRECISION||')'
		              end
		         else DATA_PRECISION||','||DATA_SCALE||')'
	        end DLENGTH
*/
	 , '('||decode(DATA_SCALE, null, nvl(DATA_PRECISION, DATA_LENGTH), DATA_PRECISION||','||DATA_SCALE)||')' DLENGTH
     , CHAR_USED
     , NULLABLE
     , DATA_DEFAULT
     , DEFAULT_LENGTH
     , OWNER
     , TABLE_NAME	 
     , DATA_TYPE_MOD
     , DATA_TYPE_OWNER
     , NUM_DISTINCT
     , LOW_VALUE
     , HIGH_VALUE
     , DENSITY
     , NUM_NULLS
     , NUM_BUCKETS
     , LAST_ANALYZED
     , SAMPLE_SIZE
     , CHARACTER_SET_NAME
     , CHAR_COL_DECL_LENGTH
     , GLOBAL_STATS
     , USER_STATS
     , AVG_COL_LEN
     , CHAR_LENGTH
     , V80_FMT_IMAGE
     , DATA_UPGRADED
     , HISTOGRAM
     , DATA_LENGTH
     , DATA_PRECISION
     , DATA_SCALE	 
  FROM DBA_TAB_COLUMNS
 WHERE OWNER = UPPER('&OWNER')
   AND TABLE_NAME = UPPER('&TABLE_NAME')
 ORDER BY COLUMN_ID
/
