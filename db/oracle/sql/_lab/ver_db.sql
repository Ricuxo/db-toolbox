@plus_find_db.sql
set lines 1000
set pages 2000
set verify off

col DB_NAME       for a15
col INSTANCE_ALIAS for a20
col INSTANCE_NAME for a15
col HOSTNAME      for a25
col VERSAO_BANCO  for a15
col STATUS        for a15
col AMBIENTE      for a25
col USUARIO_SO    for a15
col RAC           for a5
col ASM           for a5
col BACKUP        for a20
col TIPO_SENHA_SO for a20
col RESPONSAVEL_AMBIENTE for a30
col NOME_DA_APLICACAO for a30
col DESCRICAO_APLICACAO for a30


SELECT  DB_NAME,instance_alias,instance_name, 
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
				AREA_DE_NEGOCIO,
			       responsavel_ambiente,
				EMAIL_RESPONSAVEL_AMBIENTE,
			       NOME_DA_APLICACAO,
DESCRICAO_APLICACAO,
				CPU,
TOTAL_MEMORY_MB,
TOTAL_DISK_ALLOC_MB,
TOTAL_DISK_USED_MB,
DATABASE_CRIADO_POR,
OBSERVACOES
  FROM dbaprod.instancia
WHERE UPPER(instance_name) LIKE UPPER(TRIM('%&&1%'))
    OR UPPER(hostname) LIKE UPPER(TRIM('%&&1%'))
    OR UPPER(DESCRICAO_APLICACAO) LIKE UPPER(TRIM('%&&1%'))
order by DATA_ENTREGA_CRIACAO
/

undefine 1
@und

