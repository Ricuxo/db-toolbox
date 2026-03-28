CREATE FUNCTION VERIFY_FUN_GLOGIN
(username varchar2,
  password varchar2,
  old_password varchar2)
  RETURN boolean IS 
   n boolean;
   m integer;
   x integer;
   y integer;
   z integer;
   differ integer;
   isdigit boolean;
   ischar  boolean;
   ispunct boolean;
   digitarray varchar2(20);
   punctarray varchar2(25);
   chararray varchar2(52);

BEGIN 
   digitarray:= '0123456789';
   chararray:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
   punctarray:='!"#$%&()``*+,-/:;<=>?_';

   IF password = username THEN
     raise_application_error(-20001, 'Password same as or similar to user');
   END IF;

  IF length(password) < 8 THEN
      raise_application_error(-20002, 'Password length less than 8.');
   END IF;

   isdigit:=FALSE;
   x:=0;

   m := length(password);
   FOR i IN 1..10 LOOP 
      FOR j IN 1..m LOOP 
         IF substr(password,j,1) = substr(digitarray,i,1) THEN
 	     x:=x+1;
	     if x = 1 then
	        isdigit:=TRUE;
        	GOTO findchar;
	     end if;
         END IF;
      END LOOP;
   END LOOP;
   IF isdigit = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least 1 digit');
   END IF;

   <<findchar>>
   ischar:=FALSE;
   y:=0;
   FOR i IN 1..length(chararray) LOOP 
      FOR j IN 1..m LOOP 
         IF substr(password,j,1) = substr(chararray,i,1) THEN
  	     y:=y+1;
	     if y = 4 then
	            ischar:=TRUE;
	            GOTO findpunct;
	     end if;
         END IF;
      END LOOP;
   END LOOP;
   IF ischar = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least 4 characters');
   END IF;

  <<findpunct>>
  ispunct:=FALSE;
   z:=0;
   FOR i IN 1..length(punctarray) LOOP 
      FOR j IN 1..m LOOP 
         IF substr(password,j,1) = substr(punctarray,i,1) THEN
  	     z:=z+1;
	     if z = 1 then
	            ispunct:=TRUE;
	             GOTO endsearch;
	     end if;
         END IF;
      END LOOP;
   END LOOP;
   IF ispunct = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least 1 punctuation');
   END IF;

   <<endsearch>>
   -- Check if the password differs from the previous password by at least
   -- 3 letters
   IF old_password IS NOT NULL THEN
     differ := length(old_password) - length(password);

     IF abs(differ) < 3 THEN
       IF length(password) < length(old_password) THEN
         m := length(password);
       ELSE
         m := length(old_password);
       END IF;

       differ := abs(differ);
       FOR i IN 1..m LOOP
         IF substr(password,i,1) != substr(old_password,i,1) THEN
           differ := differ + 1;
         END IF;
       END LOOP;

       IF differ < 4 THEN
         raise_application_error(-20004, 'Password should differ by at \
         least 4 characters');
       END IF;
     END IF;
   END IF;
   -- Everything is fine; return TRUE ;   
   RETURN(TRUE);
END;
/




-------C&A APLICAÇÃO

CREATE OR REPLACE NONEDITIONABLE FUNCTION "SYS"."APP_CEA_VERIFY_FUNCTION" (
    username VARCHAR2,
    password VARCHAR2,
    old_password VARCHAR2
) RETURN BOOLEAN IS
    differ INTEGER;
    lang VARCHAR2(512);
    message VARCHAR2(512);
    ret NUMBER;
BEGIN
    -- Get the current context language and use UTL_LMS for messages
    lang := sys_context('userenv', 'lang');
    lang := substr(lang, 1, instr(lang, '_') - 1);
    -- Check for invalid characters "@" "$" "%"
    IF REGEXP_LIKE(password, '[@$%]') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Caractere inválido, defina outra senha');
    END IF;
    -- Check password complexity
    IF NOT ora_complexity_check(
        password,
        chars => 30,        -- Ensuring a minimum of 30 characters
        uppercase => 1,     -- At least 1 uppercase character
        lowercase => 1,     -- At least 1 lowercase character
        digit => 1,         -- At least 1 digit
        special => 1        -- At least 1 special character
    ) THEN
        RETURN FALSE;
    END IF;
    -- Check if the password differs from the previous password by at least 8 characters
    IF old_password IS NOT NULL THEN
        differ := ora_string_distance(old_password, password);
        IF differ < 8 THEN
            ret := utl_lms.get_message(28211, 'RDBMS', 'ORA', lang, message);
            RAISE_APPLICATION_ERROR(-20000, utl_lms.format_message(message, 'eight'));
       END IF;
    END IF;
 
    RETURN TRUE;
END;
/


------ C&A APLICAÇÃO 11G

create or replace NONEDITIONABLE FUNCTION APP_CEA_VERIFY_FUNCTION
(username varchar2,
  password varchar2,
  old_password varchar2)
  RETURN boolean IS 
   n boolean;
   m integer;
   x integer;
   y integer;
   z integer;
   differ integer;
   isdigit boolean;
   ischar  boolean;
   ispunct boolean;
   digitarray varchar2(20);
   punctarray varchar2(25);
   chararray varchar2(52);
BEGIN 
   digitarray := '0123456789';
   chararray := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
   punctarray := '!"#$%&()``*+,-/:;<=>?_';
   -- Verificar se a senha não contém os caracteres @, % ou $
   IF instr(password, '@') > 0 OR instr(password, '%') > 0 OR instr(password, '$') > 0 THEN
      raise_application_error(-20006, 'Password must not contain any of the following characters: @, %, $');
   END IF;
   -- Verificar se a senha tem pelo menos 30 caracteres
   IF length(password) < 30 THEN
      raise_application_error(-20007, 'Password length must be at least 30 characters.');
   END IF;
   IF password = username THEN
     raise_application_error(-20001, 'Password same as or similar to user');
   END IF;
   IF length(password) < 8 THEN
      raise_application_error(-20002, 'Password length less than 8.');
   END IF;
   isdigit := FALSE;
   x := 0;
   m := length(password);
   FOR i IN 1..10 LOOP 
      FOR j IN 1..m LOOP 
         IF substr(password,j,1) = substr(digitarray,i,1) THEN
       x := x + 1;
       if x = 1 then
          isdigit := TRUE;
          GOTO findchar;
       end if;
         END IF;
      END LOOP;
   END LOOP;
   IF isdigit = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least 1 digit');
   END IF;
   <<findchar>>
   ischar := FALSE;
   y := 0;
   FOR i IN 1..length(chararray) LOOP 
      FOR j IN 1..m LOOP 
         IF substr(password,j,1) = substr(chararray,i,1) THEN
         y := y + 1;
       if y = 4 then
              ischar := TRUE;
              GOTO findpunct;
       end if;
         END IF;
      END LOOP;
   END LOOP;
   IF ischar = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least 4 characters');
   END IF;
   <<findpunct>>
   ispunct := FALSE;
   z := 0;
   FOR i IN 1..length(punctarray) LOOP 
      FOR j IN 1..m LOOP 
         IF substr(password,j,1) = substr(punctarray,i,1) THEN
         z := z + 1;
       if z = 1 then
              ispunct := TRUE;
               GOTO endsearch;
       end if;
         END IF;
      END LOOP;
   END LOOP;
   IF ispunct = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least 1 punctuation');
   END IF;
   <<endsearch>>
   -- Verificar se a nova senha difere da senha anterior em pelo menos 4 caracteres
   IF old_password IS NOT NULL THEN
     differ := length(old_password) - length(password);
     IF abs(differ) < 3 THEN
       IF length(password) < length(old_password) THEN
         m := length(password);
       ELSE
         m := length(old_password);
       END IF;
       differ := abs(differ);
       FOR i IN 1..m LOOP
         IF substr(password,i,1) != substr(old_password,i,1) THEN
           differ := differ + 1;
         END IF;
       END LOOP;
       IF differ < 4 THEN
         raise_application_error(-20004, 'Password should differ by at least 4 characters');
       END IF;
     END IF;
   END IF;
   -- Tudo está correto; retorna TRUE
   RETURN(TRUE);
END;