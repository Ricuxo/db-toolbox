Rem 
Rem		NOME
Rem 	  ver_recovery_files.sql
Rem 	
Rem 	DESCRICAO
Rem 	  Verifica quais arquivos e tablespaces necessitam de recuperacao e o arquivo de log necessário.
Rem 	
Rem 	UTILIZACAO
Rem 	  @ver_recovery_files.sql
Rem

select file#, d.name d_name,t.name t_name, status,error
from gv$recover_file r
join gv$datafile d using(file#)
join gv$tablespace t using(ts#)
/

select archive_name from gv$recovery_log;