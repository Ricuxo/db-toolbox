-- -----------------------------------------------------------------------------
--                 WWW.PETEFINNIGAN.COM LIMITED
-- -----------------------------------------------------------------------------
-- Script Name : aud_last_logon.sql
-- Author      : Pete Finnigan
-- Date        : June 2003
-- -----------------------------------------------------------------------------
-- Description : This script can be used to find users who have not logged 
--               onto the database for a specified number of days. This script
--               analyses the audit trail and as such needs audit to be 
--               enabled with "audit session".
-- -----------------------------------------------------------------------------
-- Maintainer  : Pete Finnigan (http://www.petefinnigan.com)
-- Copyright   : Copyright (C) 2003 PeteFinnigan.com Limited. All rights
--               reserved. All registered trademarks are the property of their
--               respective owners and are hereby acknowledged.
-- -----------------------------------------------------------------------------
--  Usage      : The script provided here is available free. You can do anything 
--               you want with it commercial or non commercial as long as the 
--               copyrights and this notice are not removed or edited in any way. 
--               The scripts cannot be posted / published / hosted or whatever 
--               anywhere else except at www.petefinnigan.com/tools.htm
-- -----------------------------------------------------------------------------
-- Version History
-- ===============
--
-- Who         version     Date      Description
-- ===         =======     ======    ======================
-- P.Finnigan  1.0         Jun 2003  First Issue.
-- P.Finnigan  1.1         Oct 2004  Usage notes added
-- -----------------------------------------------------------------------------

whenever sqlerror exist rollback
set feed on
set head on
set arraysize 1
set space 1
set verify on
set pages 25
set lines 80
set termout on
clear screen

spool aud_last_logon.lis

undefine number_of_days

col username for a10
col os_username for a10
col timestamp for a9
col logoff_time for a9
col returncode for 9999
col terminal for a10
col userhost for a10


select 	a.username,
	os_username,
	a.timestamp,
	a.logoff_time,
	a.returncode,
	terminal,
	userhost
from dba_audit_session a
where (a.username,a.timestamp) in 
	(select b.username,max(b.timestamp)
		from dba_audit_session b
		group by b.username)
and a.timestamp<(sysdate-365)
/

spool off
