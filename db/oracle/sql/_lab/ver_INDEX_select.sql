SET lin 10000
SET verify off
COL TIPO for a8
COL index_owner format a15;
COL seletividade format a120;
COL COLUMN_NAME for a18

SELECT   a.index_owner, c.uniqueness, NVL (b.constraint_type, 'NORMAL') tipo,
         a.index_name, a.column_position, a.column_name,
            'Dados:-> BLevel: '
         || TRIM (TO_CHAR (c.blevel))
         || ' - FATOR DE SELETIVIDADE ( >= 90%): '
         || TO_CHAR (ROUND (  (  DECODE (c.distinct_keys,
                                         0, 1,
                                         c.distinct_keys
                                        )
                               / DECODE (c.num_rows, 0, 1, c.num_rows)
                              )
                            * 100,
                            2
                           ),
                     '999.99'
                    )
         || '% - PCT_FREE: '
         || TO_CHAR (c.pct_free)
         || ' Analyze: '
         || TO_CHAR (c.last_analyzed, 'dd-mon-rr hh24:mi') seletividade,
         c.tablespace_name
    FROM dba_ind_columns a, dba_constraints b, dba_indexes c
   WHERE a.table_name = UPPER ('&TABLE')
     AND a.index_owner = b.owner(+)
     AND a.index_name = b.constraint_name(+)
     AND a.index_owner = c.owner
     AND a.index_name = c.index_name
ORDER BY a.index_name, a.column_position
/
