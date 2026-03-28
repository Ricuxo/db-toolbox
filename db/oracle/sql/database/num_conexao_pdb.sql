select count(1) "Numero de Conexoes",p.NAME,s.INST_ID from gv$session s join gv$pdbs p using (con_id)
group by p.NAME,s.INST_ID order by p.NAME ;