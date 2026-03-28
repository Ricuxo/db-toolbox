declare

    v_daily    date := to_date('02/01/2013', 'dd/mm/yyyy');
    v_dailyest date := v_daily;
    v_aspas    char(1) := chr(39);
/*
    v_year     varchar2(4) := '';
    v_month    varchar2(2) := '';
    v_day      varchar2(2) := '';
*/
    v_partname varchar2(12) := '';
    v_command  varchar2(1000) := '';

begin

    while v_daily <= to_date('01/03/2013', 'dd/mm/yyyy') loop

        v_dailyest := v_daily -1;
        v_partname := 'P_'||to_char(v_dailyest, 'yyyy')||'_'||to_char(v_dailyest, 'mm')||'_'||to_char(v_dailyest, 'dd');
        v_command := 'alter table &OWNER.&TABLE add partition '||v_partname||' VALUES LESS THAN (TO_DATE( '
                   ||v_aspas||to_char(v_daily, 'yyyy-mm-dd hh24:mi:ss')||v_aspas||', '||v_aspas||'SYYYY-MM-DD HH24:MI:SS'||v_aspas
                   ||', '||v_aspas||'NLS_CALENDAR=GREGORIAN'||v_aspas||')) '||chr(10)
                   ||'SEGMENT CREATION DEFERRED   PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS NOLOGGING'||chr(10)
                   ||'STORAGE( INITIAL 52428800 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645  PCTINCREASE 0 FREELISTS 1'||chr(10)
                   ||'FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT) TABLESPACE '||chr(34)||'GCOB_DAT'||chr(34)||';';

        v_daily := v_daily + 1;

        dbms_output.put_line(v_command);

    end loop;

end;
