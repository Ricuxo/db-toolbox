/*  */
Rem status.sql
rem Mike Ault Burleson Consulting
rem Purpose: Run various database health scripts
rem  scripts require that dba_utilities package has been installed
rem rev 0.
Rem 13-Aug-2011
rem
clear columns
clear computes
@do_cals2
clear columns
clear computes
@libcache
clear computes
clear columns
@free2_spc
clear columns
clear computes
@extents_chk
clear columns
clear computes
@rbk1
@rbk2
@rbk3
clear columns
clear computes
@log_stat
clear columns
clear computes
@inv_obj
clear columns
clear computes
@systabs
clear columns
clear computes
@check_pool
clear columns
clear computes
@sgastat
clear columns
clear computes
@undo
clear columns
clear computes
@redo
clear columns
clear computes
@dbwr8_stat
clear columns
clear computes
ttitle off
pause Press Enter to continue
