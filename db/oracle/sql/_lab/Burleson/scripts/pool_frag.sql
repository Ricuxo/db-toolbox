/*  */
select 
decode( 
sign(ksmchsiz - 812), 
-1, (ksmchsiz - 16) / 4, 
decode( 
sign(ksmchsiz - 4012), 
-1, trunc((ksmchsiz + 11924) / 64), 
decode( 
sign(ksmchsiz - 65548), 
-1, trunc(1/log(ksmchsiz - 11, 2)) + 238, 
254 
) 
) 
) bucket, 
sum(ksmchsiz) free_space, 
count(*) free_chunks, 
trunc(avg(ksmchsiz)) average_size, 
max(ksmchsiz) biggest 
from 
sys.x$ksmsp 
where 
inst_id = userenv('Instance') and 
ksmchcls = 'free' 
group by 
decode( 
sign(ksmchsiz - 812), 
-1, (ksmchsiz - 16) / 4, 
decode( 
sign(ksmchsiz - 4012), 
-1, trunc((ksmchsiz + 11924) / 64), 
decode( 
sign(ksmchsiz - 65548), 
-1, trunc(1/log(ksmchsiz - 11, 2)) + 238, 
254 
) 
) 
) 
/ 
