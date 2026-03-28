/*  */
drop public database link orcnett7;
create public database link orcnetp5
connect to snaplog_dba identified by snapv1_98
using 'ORCNETT7';
