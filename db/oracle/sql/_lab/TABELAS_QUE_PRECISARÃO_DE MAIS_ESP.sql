-- TABELAS_QUE_PRECISARÃO_DE MAIS_ESPAÇO EM CASO DE CRESCIMENTO DE 30%
SELECT OWNER                                                                                             ,
           TABLE_NAME                                                                                   ,
           TABLESPACE_NAME                                                                         ,
           TO_CHAR((((NUM_ROWS * AVG_ROW_LEN)*1.3) -
           ((BLOCKS + EMPTY_BLOCKS) * 8192))/1024,'999999999.9')        DEFICIT_KB ,
           NUM_ROWS                                      NUMERO_DE_LINHAS                ,
           AVG_ROW_LEN                            TAMANHO_MEDIO_DA_LINHA   ,
           NUM_ROWS * AVG_ROW_LEN          ESPACO_OCUPADO_POR_DADOS ,
           BLOCKS                                          BLOCOS_OCUPADOS                ,
           EMPTY_BLOCKS                          BLOCOS_VAZIOS                  ,
           BLOCKS + EMPTY_BLOCKS                BLOCOS_TOTAL                     ,
           BLOCKS * 8                              BLOCOS_OCUPADOS_KB      ,  -- DB_BLOCK_SIZE = 8K
           EMPTY_BLOCKS * 8                      BLOCOS_VAZIOS_KB                ,
           (BLOCKS + EMPTY_BLOCKS) * 8  BLOCOS_TOTAL_KB
FROM   DBA_TABLES
WHERE  ((NUM_ROWS * AVG_ROW_LEN)*1.3) >
           ((BLOCKS + EMPTY_BLOCKS) * 8192)
AND     OWNER = 'OWNER'
ORDER BY ((NUM_ROWS * AVG_ROW_LEN)*1.3) -
           ((BLOCKS + EMPTY_BLOCKS) * 8192)  DESC;                           
           