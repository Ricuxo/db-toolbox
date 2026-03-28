Rem
Rem    DESCRIÇÃO
Rem    MOSTRA AS LEITURAS LÓGICAS CUMULATIVAS E AS LEITURAS FÍSICAS REALIZADAS PARA CADA SESSÃO DE USUÁRIO, PODE SER CONSULTADO A TAXA DE HIT DE CADA
Rem    SESSÃO NA V$SESS_IO.
Rem
Rem    ATUALIZAÇÕES  (MM/DD/YY)
Rem    Daniel Borges  15/01/11 
Rem
select sess.username,
       sess_io.block_gets,
       sess_io.consistent_gets,
       sess_io.physical_reads,
       round(100*(sess_io.consistent_gets+sess_io.block_gets-sess_io.physical_reads)/
                   (decode(sess_io.consistent_gets,0,1,
                     sess_io.consistent_gets+sess_io.block_gets)),2)
                       session_hit_ration
from v$sess_io sess_io, v$session sess
where sess.sid = sess_io.sid
and sess.username is not null
and sess.sid = '&sid'
order by username;