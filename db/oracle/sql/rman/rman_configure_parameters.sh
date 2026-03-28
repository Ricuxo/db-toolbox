##!/bin/bash
##
## rman_configure_parameters.sh - Configura os parâmetros de rman nos bancos de dados
##
## Site		: http://www.hsslab.com.br
## Autor		: Ricuxo(2020)
##
## ---------------------------------------------------------------
## Este programa tem como objetivo configurar todos os bancos de dados presentes em um servidor com a mesma configuracao.
## É necessário que o script esteja no servidor
## Se for ambiente dataguard ele vai mudar uma configuração referente e deleção de archives
## Foi seguidos as melhores praticas baseados no documento da Oracle:
## https://www.oracle.com/technetwork/database/features/298772-132349.pdf - "RMAN Best Practices for Oracle Data Guard & Oracle Streams"
## Acessado em: 18/12/2020
## E recomendado usar um usuario diferente do sys (que esta no codigo), esse usuario precisara de permissao de select na v$database
##
## Exemplos:
##	$ ./rman_configure_parameters.sh
##
## ------------------------------------------------------------
#
#function parametros_primary {
#    
#    #CRIACAO DO ARQUIVO COM OS PARAMETROS
#    echo "CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS; " >> rman_parameters_primary.rman
#    echo "CONFIGURE BACKUP OPTIMIZATION ON;" >> rman_parameters_primary.rman
#    echo "CONFIGURE DEFAULT DEVICE TYPE TO 'SBT_TAPE';" >> rman_parameters_primary.rman
#    echo "CONFIGURE CONTROLFILE AUTOBACKUP ON;" >> rman_parameters_primary.rman
#    echo "CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE SBT_TAPE TO '%F'; " >> rman_parameters_primary.rman
#    echo "CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '%F'; " >> rman_parameters_primary.rman
#    echo "CONFIGURE DEVICE TYPE 'SBT_TAPE' PARALLELISM 4 BACKUP TYPE TO BACKUPSET;" >> rman_parameters_primary.rman
#    echo "CONFIGURE DEVICE TYPE DISK PARALLELISM 4 BACKUP TYPE TO BACKUPSET;" >> rman_parameters_primary.rman
#    echo "CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE SBT_TAPE TO 1; " >> rman_parameters_primary.rman
#    echo "CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK TO 1; " >> rman_parameters_primary.rman
#    echo "CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE SBT_TAPE TO 1; " >> rman_parameters_primary.rman
#    echo "CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 1; " >> rman_parameters_primary.rman
#    echo "CONFIGURE MAXSETSIZE TO UNLIMITED; " >> rman_parameters_primary.rman
#    echo "CONFIGURE ENCRYPTION FOR DATABASE OFF; " >> rman_parameters_primary.rman
#    echo "CONFIGURE ENCRYPTION ALGORITHM 'AES128'; " >> rman_parameters_primary.rman
#    echo "CONFIGURE COMPRESSION ALGORITHM 'BASIC' AS OF RELEASE 'DEFAULT' OPTIMIZE FOR LOAD TRUE ; " >> rman_parameters_primary.rman
#    echo "CONFIGURE RMAN OUTPUT TO KEEP FOR 7 DAYS; " >> rman_parameters_primary.rman
#    echo "CONFIGURE ARCHIVELOG DELETION POLICY TO BACKED UP 1 TIMES TO 'SBT_TAPE';" >> rman_parameters_primary.rman
#
#    return
#}
#
#function parametros_standby {
#
#    #CRIACAO DO ARQUIVO COM OS PARAMETROS
#    echo "CONFIGURE RETENTION POLICY TO REDUNDANCY 1; " >> rman_parameters_standby.rman
#    echo "CONFIGURE BACKUP OPTIMIZATION ON;" >> rman_parameters_standby.rman
#    echo "CONFIGURE DEFAULT DEVICE TYPE TO 'SBT_TAPE';" >> rman_parameters_standby.rman
#    echo "CONFIGURE CONTROLFILE AUTOBACKUP ON;" >> rman_parameters_standby.rman
#    echo "CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE SBT_TAPE TO '%F'; " >> rman_parameters_standby.rman
#    echo "CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '%F'; " >> rman_parameters_standby.rman
#    echo "CONFIGURE DEVICE TYPE 'SBT_TAPE' PARALLELISM 4 BACKUP TYPE TO BACKUPSET;" >> rman_parameters_standby.rman
#    echo "CONFIGURE DEVICE TYPE DISK PARALLELISM 4 BACKUP TYPE TO BACKUPSET;" >> rman_parameters_standby.rman
#    echo "CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE SBT_TAPE TO 1; " >> rman_parameters_standby.rman
#    echo "CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK TO 1; " >> rman_parameters_standby.rman
#    echo "CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE SBT_TAPE TO 1; " >> rman_parameters_standby.rman
#    echo "CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 1; " >> rman_parameters_standby.rman
#    echo "CONFIGURE MAXSETSIZE TO UNLIMITED; " >> rman_parameters_standby.rman
#    echo "CONFIGURE ENCRYPTION FOR DATABASE OFF; " >> rman_parameters_standby.rman
#    echo "CONFIGURE ENCRYPTION ALGORITHM 'AES128'; " >> rman_parameters_standby.rman
#    echo "CONFIGURE COMPRESSION ALGORITHM 'BASIC' AS OF RELEASE 'DEFAULT' OPTIMIZE FOR LOAD TRUE ; " >> rman_parameters_standby.rman
#    echo "CONFIGURE RMAN OUTPUT TO KEEP FOR 7 DAYS; " >> rman_parameters_standby.rman
#    echo "CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY;" >> rman_parameters_standby.rman
#
#    return
#}
#
##APLICACAO DO SCRIPT NOS BANCOS DE DADOS
#for SID in `ps -ef | grep pmon | awk -F\_ '{print $3}' | egrep -v '^$|\+'`
#do
#export ORACLE_SID=$SID
#export ORAENV_ASK=NO
#. oraenv
#
#$ORACLE_HOME/bin/sqlplus -s "/ as sysdba" <<EOF >/dev/null
#set pagesize 0 heading off feedback off verify off echo off trimspool on
#spool dg_${SID}.log
#select name from v\$datafile where rownum < 2;
#spool off
#spool db_role_${SID}.log
#select database_role from v\$database;
#spool off
#EOF
#
#DG=`cut -d '/' -f1,2 dg_$SID.log | sed '/^$/d'`
#ROLE=`cat db_role_${SID}.log`
#
#if [ "$ROLE" != "PRIMARY" ]
#then
#    parametros_standby
#    echo "CONFIGURE SNAPSHOT CONTROLFILE NAME TO '$DG/CONTROLFILE/snapcf_$SID.f';" >> rman_parameters_standby.rman
#    echo Database $SID >> rman_parameters_standby_$SID.log
#    $ORACLE_HOME/bin/rman "target /" cmdfile=rman_parameters_standby.rman >> rman_parameters_standby_$SID.log
#    rm dg_$SID.log
#    rm rman_parameters_standby.rman
#    rm rman_parameters_standby_$SID.log
#else
#    parametros_primary
#    echo "CONFIGURE SNAPSHOT CONTROLFILE NAME TO '$DG/CONTROLFILE/snapcf_$SID.f';" >> rman_parameters_primary.rman
#    echo Database $SID >> rman_parameters_primary_$SID.log
#    $ORACLE_HOME/bin/rman "target /" cmdfile=rman_parameters_primary.rman >> rman_parameters_primary_$SID.log
#    rm dg_$SID.log
#    rm rman_parameters_primary.rman
#    rm rman_parameters_primary_$SID.log
#fi
#done
#rm db_role_${SID}.log