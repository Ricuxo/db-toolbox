set linesize 250
col name format a40
col value format a50

SELECT   inst_id, name, VALUE, ISDEFAULT, ISSYS_MODIFIABLE, ISMODIFIED
  FROM   gv$parameter
 WHERE   UPPER(name) like UPPER('%&1%')
ORDER BY 1,2;


/* 
ISMODIFIED Indicates whether the parameter has been modified after instance startup:
     MODIFIED - Parameter has been modified with ALTER SESSION
     SYSTEM_MOD - Parameter has been modified with ALTER SYSTEM (which causes all the currently logged in sessions' values to be modified)
     FALSE - Parameter has not been modified after instance startup

ISSYS_MODIFIABLE Indicates whether the parameter can be changed with ALTER SYSTEM and when the change takes effect:
     IMMEDIATE - The change takes effect immediately.
     DEFERRED -  The change takes effect in subsequent sessions.
     FALSE -     Parameter cannot be changed 

ISDEFAULT Indicates whether the parameter is set to the default value (TRUE) 
*/