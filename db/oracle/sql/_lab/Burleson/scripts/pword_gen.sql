/*  */
create or replace function gen_pword return varchar2 as
   pi        number := 3.141592653589793238462643 ;
   seed      number ;
   pwd       varchar2(6);
   pwd_len   number := 6;          /* length of password */
begin
   dbms_output.enable(1000000);
   select to_number(to_char(hsecs)) / 8640000 into seed from v$timer ;      /*     0<= seed  < 1 */
   pwd := null ;
       FOR  j  in 1..pwd_len LOOP
          seed := power(pi + seed,5)  - trunc (power(pi + seed,5) );
          pwd := pwd || chr( 64 + 1 + trunc (seed * 26)) ;
       END LOOP;
--       dbms_output.put_line (pwd);
return pwd;
end;
/
