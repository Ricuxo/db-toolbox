declare

    p_owner 		 user_tab_columns.table_name%type  := '&owner';
    p_table 		 user_tab_columns.column_name%type := '&table';
--  p_where 		 varchar2(5000)               := '&where';

	dtformat         varchar(16) := 'yyyymmddhh24miss';
    qts              char(2) := chr(39);
    iqts			 char(13) := '|| chr(39) ||';
    pipe             char(2) := '||';
	v_select         long := '';
    v_presel         long := 'select '||qts||'insert into ';
    v_prosel		 varchar2(30) := ' );'||qts||' from '|| p_owner || '.' || p_table ||' ;';
    maxid            number(4) := 0;

begin

	execute immediate 'alter session set nls_date_format = '||qts||dtformat||qts;
    execute immediate 'alter session set nls_numeric_characters = '||qts||'.,'||qts;

	select max(column_id)
      into maxid
      from dba_tab_columns
	 where owner = p_owner
       and table_name = p_table;

    for c in (select owner
                   , table_name
                   , column_name
                   , data_type
                   , data_length
                   , data_precision
                   , data_scale
                   , nullable
                   , column_id
                   , char_length
                from dba_tab_columns
               where owner = p_owner
                 and table_name = p_table
               order by column_id
             )
	loop
    
		if c.column_id = 1 then

		    v_presel := v_presel || c.owner ||'.'|| c.table_name || ' ( ';

		end if;

        if c.data_type in ('CHAR','CLOB','LONG','VARCHAR2','NCHAR','NVARCHAR2','NCLOB') then

		    v_select := v_select || qts || iqts || c.column_name || iqts || qts;

		elsif c.data_type in ('FLOAT','NUMBER') then

		    v_select := v_select || qts || pipe || c.column_name || pipe || qts;

		elsif c.data_type in ('DATE') then

			v_select := v_select || qts || iqts || 'to_date(' || c.column_name || ', ' || qts || dtformat || qts || ')' || iqts || qts;

		end if;

		if maxid = c.column_id then

            v_presel := v_presel || c.column_name || ') VALUES ( ';

		else

			v_select := v_select || ', ';
            v_presel := v_presel || c.column_name || ', ';

		end if;

    end loop;

	v_select := v_presel || v_select || v_prosel;

	dbms_output.put_line('alter session set nls_numeric_characters = '||qts||'.,'||qts||';');
    dbms_output.put_line(v_select);

end;
/
