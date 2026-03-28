@plus_find_db.sql
set lines 1000
set pages 2000
set verify off

col INSTANCE_NAME for a15
col HOSTNAME      for a25
col VERSAO_BANCO  for a15
col STATUS        for a15
col AMBIENTE      for a40
col USUARIO_SO    for a15
col RAC           for a5
col ASM           for a5
col BACKUP        for a20
col TIPO_SENHA_SO for a20

SELECT  instance_name, 
                               hostname, 
                               versao_banco, 
                               status, 
                               ambiente, 
                               usuario_so,
                               senha, 
                               rac, 
                               asm, 
                               backup, 
                               tipo_senha_so,
                               database_criado_por,
			       responsavel_ambiente,
			       DATA_ENTREGA_CRIACAO,
			       NOME_DA_APLICACAO
  FROM dbaprod.instancia
WHERE UPPER(instance_name) LIKE UPPER(TRIM('%&&1%'))
    OR UPPER(hostname) LIKE UPPER(TRIM('%&&1%'))
    OR UPPER(DESCRICAO_APLICACAO) LIKE UPPER(TRIM('%&&1%'))
order by DATA_ENTREGA_CRIACAO
/

UNDEFINE 1

