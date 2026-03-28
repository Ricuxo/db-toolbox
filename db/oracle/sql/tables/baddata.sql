drop package body baddata;
drop package baddata;

REM BADDATA.SQL 
REM
REM  Purpose:   The purpose of this package is to identify invisibly
REM             corrupted dates , numbers and character strings 
REM
REM USAGE
REM ~~~~~
REM  The BADDATA package allows you to check a named table, schema or 
REM  entire database for corrupt DATE , NUMBER and CHAR/VARCHAR2 values.
REM  The idea is that you run this package to get a list of columns which 
REM  currently contain data which seems to be corrupt.
REM  The output shows bad row counts 
REM 
REM  Please note this is an example script only.
REM  There is no guarantee associated with the output it presents.
REM
REM  Steps to install:
REM     1. Install this package in the SYS schema
REM        Eg: connect internal
REM            @baddata
REM        This should create a BADDATA$$ control table and a
REM        BADDATA package.
REM        If installing in a 7.1 database then comment out the
REM        call to DBMS_APPLICATION_INFO below.
REM
REM  Steps to use:
REM     1. Populate the BADDATA$$ table with any tables / columns to ignore
REM        If you are not sure you can ignore this step for now.
REM     2. Ensure SPOOL is enabled to catch output and enable SERVEROUT
REM        Eg:
REM             spool mybaddata.log
REM             execute dbms_output.enable(1000000);
REM             set serveroutput on
REM     3. Run one of:
REM             BadData.CheckDB;
REM             BadData.CheckSchema('SCHEMANAME');
REM             BadData.CheckObject('SCHEMANAME','TABLENAME');
REM        to check the entire database / named schema or named table
REM        This will run until all requested items are scanned or
REM        an error occurs.
REM        If any bad columns are found then the tablename / column and 
REM        row counts are reported
REM
REM     4. If an error occurs results so far are dumped.
REM        Depending on the error you may then:
REM             BadData.LastError; to see the error again
REM             BadData.Continue;  to re-start processing at the table
REM                                we just errored on
REM             BadData.Skip;      to mark that we should skip the
REM                                table we errored on by inserting
REM                                a row in BADDATA$$
REM     5. If you want some SQL to look at the failing rows in a table
REM        in more detail use the GetSQL call:
REM             BadData.GetSQL('OWNER','TABLENAME')
REM                to give a select statement for the named table
REM
REM  Notes: 
REM     This package keeps the name of the current owner/table being 
REM     scanned in V$SESSION in the MODULE and ACTION columns.
REM     This can be used to monitor progress.
REM 
REM     This script should not be used against the SYS schema.
REM
REM =====================================================================
REM Set serverout on and enable a large buffer
REM
set serverout on
execute dbms_output.enable(1000000);

REM =====================================================================
REM Table BADDATA$$
REM =====================================================================
REM   This table contains information on Schemas, Tables, Columns
REM   and column data values which can be ignored whilst checking for
REM   suspect values by the BADDATA package
REM 
REM   The table columns are:
REM     ITEM            This determines what this BADDATA$$ row means:
REM                       OWNER   skips the entire schema for OWNER
REM                       TABLE   skips the entire OWNER . TABLE_NAME
REM                       COLUMN  skips COLUMN_NAME in OWNER . TABLE_NAME
REM     OWNER           Case sensitive schema name to ignore
REM     TABLE_NAME      Case sensitive table name to ignore
REM     COLUMN_NAME     Case sensitive column name to ignore
REM     BOOT            Should be NULL. Only rows inserted by this script
REM                     should have a value of 1 allowing this script
REM                     to be re-run without losing data.
REM                     This script will delete rows with a value 1.
REM
create table BADDATA$$ (
        item            varchar2(10),   /* COLUMN, TABLE, OWNER */ 
        owner           varchar2(30),
        table_name      varchar2(30),
        column_name     varchar2(30),
        text            varchar2(500), /* Description */
        boot            number
);
create index i_BADDATA$$ on BADDATA$$(
        item, owner, table_name, column_name
);

REM =====================================================================
REM Delete pre-existing BOOT data from this script
REM =====================================================================
REM
delete from BADDATA$$ where boot=1;

REM =====================================================================
REM Insert some known special tables / columns into BADDATA$$
REM =====================================================================
REM
insert into BADDATA$$ values 
  ('OWNER','SYS',null,null,'Dont check SYS on DB check',1 );
insert into BADDATA$$ values 
  ('TABLE','SYS','BADDATA$$',null,'Dont check myself',1 );
insert into BADDATA$$ values 
  ('TABLE','SYS','SUMDEP$',null,'P_REF_TIME contains 00-000-00 dates',1);
insert into BADDATA$$ values 
  ('TABLE','SYS','SUMDETAIL$',null,'SPARE4 contains 00-000-00 dates',1);
insert into BADDATA$$ values 
  ('COLUMN','SYS','USER$','PTIME','PTIME contains 00-000-00 dates',1);
insert into BADDATA$$ values 
  ('COLUMN','SYS','USER$','EXPTIME','EXPTIME contains 00-000-00 dates',1);
insert into BADDATA$$ values 
  ('COLUMN','SYS','USER$','LTIME','LTIME contains 00-000-00 dates',1);
commit;

REM 
REM =====================================================================
REM BadData Package
REM =====================================================================
REM
REM
CREATE OR REPLACE PACKAGE BadData
AS
 --
  PROCEDURE CheckDb( DoChars BOOLEAN default FALSE ) ;
  PROCEDURE CheckSchema( vowner varchar2, DoChars BOOLEAN default False ) ;
  PROCEDURE CheckObject( vowner varchar2, vtable_name varchar2,
			  		  DoChars BOOLEAN default False ) ;
  PROCEDURE LastError;
  PROCEDURE Continue;
  PROCEDURE GetSQL( vOwner varchar2 , vTable varchar2 ) ;
  PROCEDURE Skip;
 --
END BadData;
/

REM =====================================================================
REM BadData Package Body
REM =====================================================================
REM
CREATE OR REPLACE PACKAGE BODY BadData
AS
 --
  DEBUG   boolean:=FALSE;               
  DoCharCols boolean:=FALSE;	
 --
 --
 --
  TYPE t_Col  IS TABLE OF VARCHAR2(40) INDEX BY BINARY_INTEGER;
  Col  t_Col;
  Typ  t_Col;
 --
  TYPE t_Num  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  badCnt  t_Num;
  Mxl  t_Num;
 --
  NCols INTEGER;
 --
 -- Use these to save current location for error reporting
 --
  Command   varchar2(10);
  OnOwner   varchar2(30);
  OnTable   varchar2(30);
  OnColumn  varchar2(30);
  Pos       varchar2(255);
  Stmt      varchar2(32767);  -- Keep the core statement global for errors
  Frm       varchar2(32767);  -- Keep the FROM ... WHERE ... here
  Err       varchar2(32767);
 --
 -- =====================================================================
 -- PRIVATE Putlines(txt) 
 --   Writes a char string to DBMS_OUTPUT spliting lines as it goes
 --
  PROCEDURE putlines( txt varchar2 ) 
  IS
    p integer:=1;
    len integer;
    LineLen number:=80;
    pos integer;
  BEGIN
    len:=length(txt);
    while (p<len) loop
      pos:=instr(substr(txt,p,LineLen),chr(10));
      if pos<LineLen and pos>0 then
        dbms_output.put_line(substr(txt,p,pos-1));
        p:=p+pos;
      else
        dbms_output.put_line(substr(txt,p,LineLen));
        p:=p+LineLen;
      end if;
    end loop;
  END;
 --
 -- =====================================================================
  PROCEDURE Intro 
  IS 
  BEGIN
   putlines('The output below shows SCHEMA,TABLE and COLUMN name for columns');
   putlines('which appear to contain corrupt data.');
   putlines('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
   dbms_output.new_line;
  END;
 -- =====================================================================
 -- PRIVATE BuildStmt( owner, table, star )
 --  Builds a SQL statement to scan OWNER.TABLE.
 --  If RID is TRUE all rows are selected, otherwise just the rows
 --  we are interested in. 
 --
  PROCEDURE BuildStmt( vowner varchar2, vtable_name varchar2, rid boolean ) 
  IS
    sep  varchar2(10);
    SM   varchar2(10):='SUM';
   --
    CURSOR C_ChkCols( vowner varchar2, vtable_name varchar2) IS
      SELECT rownum, column_name, data_length, data_type
       FROM dba_tab_columns T
      WHERE owner=vowner and table_name=vtable_name
        and data_type in ('DATE','NUMBER','CHAR','VARCHAR2')
        and NOT EXISTS 
                ( select 1 from BADDATA$$ C
                   where c.item='COLUMN'
                     and c.owner=t.owner
                     and c.table_name=t.table_name
                     and c.column_name=t.column_name
                )
    ;
   --
  BEGIN
    Pos:='BuildStmt: Begin';
    stmt:='SELECT ';
   --
    if rid THEN
      stmt:=stmt||'TAB.rowid '||chr(10);
      SM:=' ';
    else
      stmt:=stmt||'count(*) '||chr(10);
    end if;
   --
    Pos:='BuildStmt: Build Select';
    NCols:=0;
    FOR R in C_ChkCols(vowner,vtable_name)
    LOOP
     IF (R.data_type='DATE' OR R.data_type='NUMBER' or DoCharCols) THEN
      NCols:=Ncols+1;
      OnColumn:=R.column_name;
      Col(NCols):=R.column_name;
      Mxl(Ncols):=R.data_length;
      Typ(Ncols):=R.data_type;
      IF rid THEN
        stmt:=stmt||',dump("'||R.column_name||'") '|| chr(10);
      ELSE
        badCnt(NCols):=null;
	if (R.data_type = 'DATE') then
          stmt:=stmt||','||SM||'(decode("'||R.column_name||
		'","'||R.column_name||'"+0,0,1))'||chr(10);
	elsif (R.data_type = 'NUMBER') then
          stmt:=stmt||','||SM||'(decode("'||R.column_name||
		'","'||R.column_name||'"/1,0,1))'||chr(10);
	else
          stmt:=stmt||','||SM||'(decode(sign('||R.data_length||
		'- nvl(length("'||R.column_name||'"),0)),-1,1,0))'||chr(10);
	end if;
      END IF;
     END IF;
    END LOOP;
    IF (NCols<=0) THEN
        return;
    END IF;
    frm:=' FROM "'||vowner||'"."'||vtable_name||'" TAB WHERE (';
    sep:=' ';
    Pos:='BuildStmt: Build WHERE';
    FOR n IN 1 .. NCols
    LOOP
      OnColumn:=Col(n);
      if (Typ(n) = 'DATE') then
        frm:=frm||chr(10)||sep||'("'||Col(n)||'"!="'||Col(n)||'"+0)';
      elsif (Typ(n) = 'NUMBER') then
        frm:=frm||chr(10)||sep||'("'||Col(n)||'"!="'||Col(n)||'"/1)';
      else
        frm:=frm||chr(10)||sep||'(nvl(length("'||Col(n)||'"),0)>'||Mxl(n)||')';
      end if;
      sep:=' OR ';
    END LOOP;
    frm:=frm||' )';
   --
    stmt:=stmt||frm;
  END;
 --
 -- =====================================================================
 -- PRIVATE TableOK( owner, table )
 --  Internal function to check a named TABLE for suspicious data
 --
  FUNCTION TableOK( vowner varchar2, vtable_name varchar2) RETURN Boolean
  IS
    n    integer;
    rows integer;
    cur  integer;
    ok   boolean;
    cnt  number;
   --
  BEGIN
    IF debug then
       dbms_output.put_line('Checking '||vowner||'.'||vtable_name);
    end if;
   -- 
   -- WARNING:  The line below must be commented out in Oracle7.1
   --           as DBMS_APPLICATION_INFO does not exist until 7.2
   --
    DBMS_APPLICATION_INFO.Set_module('BadData: '||vowner,vtable_name);
   --
    OnOwner:=vowner;
    OnTable:=vtable_name;
    OnColumn:=null;
   --
    BuildStmt( vowner,vtable_name,false );
   --
    IF (NCols=0) THEN
        dbms_output.put_line(' -- Object '||vowner||'.'||vtable_name|| ' not found !!!');
        return(FALSE);
    END IF;
   --
    IF debug then putlines(stmt); end if;
   --
    Pos:='TableOK: Open Cursor';
    OnColumn:=null;
    cur:= DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(cur,stmt, dbms_sql.native);
    DBMS_SQL.DEFINE_COLUMN(cur,1,cnt);
    FOR n in 1 .. NCols
    LOOP
     DBMS_SQL.DEFINE_COLUMN(cur,n+1,badCnt(n));
    END LOOP;
   --
    Pos:='TableOK: Execute';
    rows:= DBMS_SQL.EXECUTE_AND_FETCH(cur);
   --
    ok:=TRUE;
    IF rows > 0 THEN
     Pos:='TableOK: Check Result';
     DBMS_SQL.COLUMN_VALUE(cur,1,cnt);
     IF (cnt>0) THEN
      DBMS_OUTPUT.PUT_LINE('REM '||vowner||'.'||vtable_name||' has '||cnt||
        ' suspect rows');
      FOR n in 1 .. NCols
      LOOP
        OnColumn:=Col(n);
        DBMS_SQL.COLUMN_VALUE(cur,n+1,badCnt(n));
        if (badCnt(n)>0) then
          DBMS_OUTPUT.PUT('rem Column '||Col(n));
          DBMS_OUTPUT.PUT_LINE(' has '||badCnt(n)||' Bad '||Typ(n));
          ok:=false;
          dbms_output.new_line;
        end if;
       END LOOP;
       if (not OK) then
            DBMS_OUTPUT.PUT_LINE('REM ');
            DBMS_OUTPUT.PUT_LINE('REM Use this SQL to see the bad row/s:');
            dbms_output.new_line;
    	    GetSQL(vowner,vtable_name);
       end if;
       dbms_output.new_line;
     END IF;
     DBMS_SQL.CLOSE_CURSOR(cur);
     return(ok);
    END IF;
   --
    DBMS_OUTPUT.PUT_LINE(vowner||'.'||vtable_name||' ERROR '||sqlerrm);
    DBMS_SQL.CLOSE_CURSOR(cur);
    return(false);
  END;
 --
 -- =====================================================================
 -- PRIVATE SchemaOK( owner, table )
 --  Internal function to check a named SCHEMA for suspicious data
 --  If TABLE is specified this is the start point. If NULL all tables
 --  for this schema are scanned.
 --
  FUNCTION SchemaOK( vowner varchar2, vStartTable varchar2 default NULL ) 
  RETURN Boolean
  IS
    CURSOR C_Tables( vowner varchar2, vStartTable varchar2 ) IS
      SELECT table_name
       FROM dba_tables T
      WHERE owner=vowner
        and (vStartTable is null OR table_name>=vStartTable)
        and NOT EXISTS 
                ( select 1 from BADDATA$$ C
                   where c.item='TABLE'
                     and c.owner=t.owner
                     and c.table_name=t.table_name
                )
      order by table_name
    ;
   --
    ok  boolean:=TRUE;
    nCount number := 0;
  BEGIN
    Pos:='SchemaOK';
    OnOwner:=vowner;
    OnTable:=null;
    OnColumn:=null;
    Stmt:=null;
   --
    FOR T in C_Tables( vowner,vStartTable ) 
    LOOP
        IF NOT TableOK(vowner,T.table_name) THEN
          ok:=false;
        END IF;
        nCount := nCount + 1;
    END LOOP;
    IF nCount = 0 THEN
       dbms_output.put_line(' -- Owner '||vowner||' not found !!!');
       ok:=false;
    END IF;
    return(ok);
  END;
 --
 -- =====================================================================
 -- PRIVATE DbOK( owner, table )
 --  Internal function to check an entire database.
 --  Owner / Table specify a starting owner / table to use.
 --
  FUNCTION DbOK( vStartOwner varchar2 default null,
                 vStartTable varchar2 default null  ) RETURN Boolean
  IS
    CURSOR C_Users IS
      SELECT username FROM dba_users 
        WHERE (vStartOwner is null OR username>=vStartOwner)
        AND NOT EXISTS
                (select 1 from BADDATA$$
                  where item='OWNER' 
                    and owner=username)
        order by username
    ;
   --
    ok  boolean:=true;
  BEGIN
    Pos:='DbOK';
    OnOwner:=null;
    OnTable:=null;
OnColumn:=null;
    Stmt:=null;
   --
    FOR U in C_Users
    LOOP
        IF NOT SchemaOK(U.username,vStartTable) THEN
         ok:=false;
        END IF;
    END LOOP;
    return(ok);
  END;
 --
 -- =====================================================================
 -- PUBLIC FUNCTIONS
 -- =====================================================================
 -- PUBLIC Object( owner, table )
 --  External interface to check an OBJECT (OWNER.TABLE)
 --
  PROCEDURE OBJECT( vowner varchar2, vtable_name varchar2) 
  IS
  BEGIN
    Command:='OBJECT';
    if (TableOK(vowner,vtable_name)) then
        DBMS_OUTPUT.PUT_LINE('Table check for '||vowner||'.'||vtable_name||
                ' found no corrupt data');
    end if;
    Command:=null;
  EXCEPTION
    When others THEN
        Err:=sqlerrm;
        LastError;
        raise;
  END;
 --
 --  External interface to check a schema database
 --
  PROCEDURE CheckObject( vowner varchar2, vtable_name varchar2, 
                         DoChars BOOLEAN default FALSE ) 
  IS
  BEGIN
    DoCharCols:=DoChars;
    Object(vowner,vtable_name);
  END;
 --
 -- =====================================================================
 -- PUBLIC Schema( owner, table )
 --  External interface to check a SCHEMA (OWNER)
 --
  PROCEDURE Schema( vowner varchar2, vStartTable varchar2 default NULL ) 
  IS
  BEGIN
    Command:='SCHEMA';
    if (SchemaOK(vowner,vStartTable)) then
        DBMS_OUTPUT.PUT_LINE('Schema check for '||vowner||
                ' found no corrupt data');
    end if;
    Command:=null;
  EXCEPTION
    When others THEN
        Err:=sqlerrm;
        LastError;
        raise;
  END;
 --
 --  External interface to check a schema database
 --
  PROCEDURE CheckSchema( vowner varchar2, DoChars BOOLEAN default FALSE ) 
  IS
  BEGIN
    DoCharCols:=DoChars;
    Intro;
    Schema(vowner);
  END;
 --
 -- =====================================================================
  PROCEDURE Db ( vStartOwner varchar2 default null,
                 vStartTable varchar2 default null  ) 
  IS
  BEGIN
    Command:='DB';
    if (DbOK(vStartOwner,vStartTable)) then
        DBMS_OUTPUT.PUT_LINE('CheckDB found no corrupt data');
    end if;
    Command:=null;
  EXCEPTION
    When others THEN
        Err:=sqlerrm;
        LastError;
        raise;
  END;
 --
 --  External interface to check a complete database
 --
  PROCEDURE CheckDb( DoChars BOOLEAN default FALSE ) 
  IS
  BEGIN
    DoCharCols:=DoChars;
    Intro;
    DB;
  END;
 --
 -- =====================================================================
 -- PUBLIC Continue( )
 --  External interface to continue processing where we left off in 
 --  case of Object, Schema or DB checks
 --
  PROCEDURE Continue
  IS
    Tab varchar2(30);
    Own varchar2(30);
  BEGIN
    Tab:=OnTable;
    Own:=OnOwner;
    IF Command is not null THEN
      dbms_output.put_line('CONTINUING Check'||Command||
                ' from '||Own||'.'||Tab);
      dbms_output.new_line;
    ELSE
      dbms_output.put_line('Nothing to CONTINUE from...');
      return;
    END IF;
    IF Command='DB' THEN
        DB(Own,Tab);
    ELSE
      IF Command='SCHEMA' THEN
        Schema(Own,Tab);
      ELSE
        IF Command='OBJECT' THEN
          Object(Own,Tab);
        ELSE 
          dbms_output.put_line('Cannot CONTINUE '||Command);
        END IF;
      END IF;
    END IF;
  END;
 --
 -- =====================================================================
 -- PUBLIC GetSQL( owner, table )
 --  External interface to show an SQL statement which selects
 --  suspect rows from OWNER.TABLE
 --  
  PROCEDURE GetSQL( vOwner varchar2 , vTable varchar2 ) 
  IS
  BEGIN
    BuildStmt(vowner,vtable,true);
    putlines(stmt);
    dbms_output.put_line(';');
  END;
 --
 -- =====================================================================
 -- PUBLIC LastError
 --  Displays the last stored error from this package 
 --
  PROCEDURE LastError
  IS
  BEGIN
        dbms_output.new_line;
        dbms_output.put_line('Last BadData Error:');
        dbms_output.put_line(' Pos: '||Pos);
        dbms_output.put_line('  At: '||OnOwner||'.'||OnTable||'.'||OnColumn);
        dbms_output.put_line('Stmt:');
        putlines(Stmt);
        dbms_output.put_line('Error:');
        putlines(Err);
  END;
 --
 -- =====================================================================
 -- PUBLIC Skip
 --  If a BADDATA.CheckDB / SCHEMA / OBJECT errored then the object name
 --  we were on is marked for skipping over in the BADDATA$$ table.
 --
  PROCEDURE Skip
  IS
  BEGIN
    IF Command is not null THEN
      dbms_output.put_line('Inserting '||OnOwner||'.'||OnTable||
        ' into BADDATA$$ to skip it' );
      insert into BADDATA$$ values 
       ('TABLE',OnOwner,OnTable,null,'User request to SKIP this',0 );
      COMMIT;
    ELSE
      dbms_output.put_line('No error occured to SKIP');
    END IF;
   END;
 --
 -- =====================================================================
 --
BEGIN
  -- Initialize DBMS_OUTPUT
  dbms_output.enable(1000000);
END;
/

REM =====================================================================
REM END of BADDATA.SQL
REM =====================================================================


exec baddata.checkobject('USERSYN','FIS_LANCAMENTO_FISCAL');
