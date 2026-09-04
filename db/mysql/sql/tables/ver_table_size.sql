-- Top 20 tabelas por tamanho em airflow_cambio e airflow
SELECT 
  table_schema                                        AS banco,
  table_name                                          AS tabela,
  ROUND(data_length/1024/1024/1024, 2)                AS data_GB,
  ROUND(index_length/1024/1024/1024, 2)               AS index_GB,
  ROUND((data_length+index_length)/1024/1024/1024, 2) AS total_GB,
  FORMAT(table_rows, 0)                               AS linhas_estimadas
FROM information_schema.tables
WHERE table_schema IN ('airflow_cambio', 'airflow')
ORDER BY total_GB DESC
LIMIT 20;