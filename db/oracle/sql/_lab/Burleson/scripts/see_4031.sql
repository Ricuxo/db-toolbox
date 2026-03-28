/*  */
column kghlurcr heading "RECURRENT|CHUNKS" 
column kghlutrn heading "TRANSIENT|CHUNKS" 
column kghlufsh heading "FLUSHED|CHUNKS" 
column kghluops heading "PINS AND|RELEASES" 
column kghlunfu heading "ORA-4031|ERRORS" 
column kghlunfs heading "LAST ERROR|SIZE" 

select 
kghlurcr, 
kghlutrn, 
kghlufsh, 
kghluops, 
kghlunfu, 
kghlunfs 
from 
sys.x$kghlu 
where 
inst_id = userenv('Instance') 
/ 
