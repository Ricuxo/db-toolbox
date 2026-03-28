Rem
Rem    DESCRIÇÃO
Rem    Mostra objetos cujos blocos estão atualmente no cache de buffer do banco de dados
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem    Daniel Borges  15/01/11 
Rem
select object_name, object_type, count(*) num_buff
from x$bh a, sys.dba_objects b
where a.obj = b.object_id
and owner not in ('SYS','SYSTEM')
group by object_name, object_type;