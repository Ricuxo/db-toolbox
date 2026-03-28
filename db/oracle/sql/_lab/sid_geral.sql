undef sid
undef HASH_VALUE
column username format a20
column osuser format a20
column machine format a30
column program format a30
column module format a30
columN logon_time FORM A19
columN DT_HR_ATUAL FORM A19
set pages 5000 lines 120
set verify off
def sid = &&sid
prompt########################################################################################################################
prompt##          Informacoes da sessao do usuario                                                                          ##
prompt########################################################################################################################
@sid

column event format a30
column p1text format a20
column p2text format a20
column p3text format a20
prompt########################################################################################################################
prompt##          Informacoes de WAIT da sessao do usuario                                                                  ##
prompt########################################################################################################################
@w_sid

prompt########################################################################################################################
prompt##        Informacoes do SQL sendo executado pelo usuario                                                             ##
prompt########################################################################################################################
@sql


prompt########################################################################################################################
prompt# "LOCK" - Informacoes das sessoes que estao esperando pelo SID(sessao) informado.                                    ##
prompt######################################################################################################################## 
column sid heading 'sid' format 999999999
column username heading 'username' format a10
column spid heading 'spid' format 999999999
column lockwait heading 'lockwait' format a17
column sql_text heading 'sql_text' format a50
@lock_sid
@lock1


prompt########################################################################################################################
prompt##        Cursores(sql) utilizados pela sessao                                                                        ##
prompt########################################################################################################################
@oc
