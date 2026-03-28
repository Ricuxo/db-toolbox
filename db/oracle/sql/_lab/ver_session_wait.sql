REM " Script mostra LISTA DE EVENTOS DE ESPERA SOFRIDOS pela sessão"
REM " Autor - Luiz Noronha - 26/04/2010"
REM 

REM The colum 


SET heading 		ON;

col WAIT_CLASS 		for a15
col USERNAME		for a30

UNDEFINE SID

select  a.sid,
        b.username,
        a.wait_class,
        a.total_waits,
        round((a.time_waited / 100),2) time_waited_secs
from    sys.v$session_wait_class a,
        sys.v$session b
where   b.sid = a.sid and
        b.username is not null and
        a.wait_class != 'Idle' and
        a.sid = &sid
order by 5 desc;

