-- -----------------------------------------------------------------------------------
-- File Name    : @datafile_hot.sql 
-- Author       : Henrique
-- Description  : Verificar datafiles com maior tempo de espera.Retirado do Livro OWI
-- Call Syntax  : @datafile_hot.sql
--
-- Last Modified: 27/07/2016
-- -----------------------------------------------------------------------------------


col file_name for a60
select a.file#,
 b.file_name,
 a.singleblkrds,
 a.singleblkrdtim,
 a.singleblkrdtim/a.singleblkrds average_wait
 from   v$filestat a, dba_data_files b
 where  a.file# = b.file_id
 and    a.singleblkrds > 0
 order by average_wait;
