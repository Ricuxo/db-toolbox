/*************************************************************************************/
/***********            SCRIPT PARA GERENCIAR TABLESPACE                **************/
/***********							        **************/
/***********  Funcao: Consulta tamanho das tablespace	 	        **************/
/***********							        **************/
/***********  Obs: Ajuste todos os paths para geracao de spool com nome **************/
/***********  	 de ambiente e data                                     **************/
/***********							        **************/
/*************************************************************************************/
set pages 50
break on report

COLUMN "Total Size Mb"		FORMAT 999999.99
COLUMN "Used Mb"		FORMAT 999999.99
COLUMN "Free Mb"		FORMAT 999999.99
COLUMN "%Free"			FORMAT 999999.99
compute sum of "Total Size Mb" 	on report
compute sum of "Used Mb" 	on report
compute sum of "Free Mb" 	on report

select
	a.tablespace_name		"Tablespace",
	trunc(a.total,2)		"Total Size Mb",	
	trunc((a.total - b.free),2) 	"Used Mb",
	trunc(b.free,2)			"Free Mb",
	trunc((b.free * 100) / a.total,2) "%Free"
from	(select sum(bytes)/1024/1024 total, tablespace_name from dba_data_files group by tablespace_name) a,
	(select sum(bytes)/1024/1024 free,  tablespace_name from dba_free_space group by tablespace_name) b
where
	b.tablespace_name = a.tablespace_name --AND A.TABLESPACE_NAME LIKE '%ATT%'
order by 5,1 ;
