set line 1000
col name for a50
col VALUE for a20
col DESCRIPTION for a200

select nam.ksppinm NAME, val.KSPPSTVL VALUE, KSPPDESC Description
from x$ksppi nam, x$ksppsv val where nam.indx = val.indx and nam.ksppinm like '%&1%';

clear columns

