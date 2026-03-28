col component form a30
col parameter form a20


select INST_ID,
       COMPONENT,
       OPER_TYPE,     
       OPER_MODE,
       PARAMETER,
       INITIAL_SIZE/1024/1024 INITIAL_MB,
       TARGET_SIZE/1024/1024 TARGET_MB,
       FINAL_SIZE/1024/1024 FINAL_MB,
       STATUS,
       START_TIME,
       END_TIME
from GV$SGA_RESIZE_OPS;