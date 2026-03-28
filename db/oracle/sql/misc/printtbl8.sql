--MOSTRAR RESULTADO DO SQL VERTICAL
--
-- EXEMPLO DE SAÍDA:
--
--
--SQL> @printtbl8.sql 'select * from v$instance';
--old  17:                     replace( '&1', '"', ''''),
--new  17:                     replace( 'select * from v$instance', '"', ''''),
--INSTANCE_NUMBER                    : 1
--INSTANCE_NAME                      : VENUSCDB
--HOST_NAME                          : dbserver12c
--VERSION                            : 12.1.0.2.0
--STARTUP_TIME                       : 16-sep-2017 21:40:44
--STATUS                             : OPEN
--PARALLEL                           : NO
--THREAD#                            : 1
--ARCHIVER                           : STOPPED
--LOG_SWITCH_WAIT                    :
--LOGINS                             : ALLOWED
--SHUTDOWN_PENDING                   : NO
--DATABASE_STATUS                    : ACTIVE
--INSTANCE_ROLE                      : PRIMARY_INSTANCE
--ACTIVE_STATE                       : NORMAL
--BLOCKED                            : NO
--CON_ID                             : 0
--INSTANCE_MODE                      : REGULAR
--EDITION                            : EE
--FAMILY                             :

set serveroutput on
set linesize 200
declare
    l_theCursor    integer default dbms_sql.open_cursor;
    l_columnValue    varchar2(4000);
    l_status        integer;
    l_descTbl    dbms_sql.desc_tab;
    l_colCnt        number;
    procedure execute_immediate( p_sql in varchar2 )
    is
    BEGIN
        dbms_sql.parse(l_theCursor,p_sql,dbms_sql.native);
        l_status := dbms_sql.execute(l_theCursor);
    END;
begin
    execute_immediate( 'alter session set nls_date_format=
                        ''dd-mon-yyyy hh24:mi:ss'' ');
    dbms_sql.parse(    l_theCursor,
                    replace( '&1', '"', ''''),
                    dbms_sql.native );
    dbms_sql.describe_columns( l_theCursor,
                            l_colCnt, l_descTbl );
    for i in 1 .. l_colCnt loop
        dbms_sql.define_column( l_theCursor, i,
                                l_columnValue, 4000 );
    end loop;
    l_status := dbms_sql.execute(l_theCursor);
    while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
        for i in 1 .. l_colCnt loop
            dbms_sql.column_value( l_theCursor, i,
                                l_columnValue );
            dbms_output.put_line
                ( rpad( l_descTbl(i).col_name,
         35 ) || ': ' || l_columnValue );
        end loop;
        dbms_output.put_line( '-----------------' );
    end loop;
    execute_immediate( 'alter session set nls_date_format=
                        ''dd-MON-yy'' ');
exception
    when others then
        execute_immediate( 'alter session set
                        nls_date_format=''dd-MON-yy'' ');
        raise;
end;
/