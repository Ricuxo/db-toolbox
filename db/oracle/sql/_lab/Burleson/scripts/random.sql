/*  */
create or replace package random as
function rndint(r in number) return number;
function rndflt return number;
end;
/

create or replace package body random as
m constant number :=100000000000000;  
m1 constant number:=1000000000000;     
b constant number:=31415821;   
a number;                      
the_date date;                
days number;                   
secs number;                   
function mult(p in number, q in number) return number is
   p1 number;
   p0 number;
   q1 number;
   q0 number;
   x  number;
BEGIN
   p1:=trunc(p/m1);
   p0:=mod(p,m1);
   q1:=trunc(q/m1);
   q0:=mod(q,m1);
   x:=mod((mod(p0*q1+p1*q0,m1)*m1+p0*q0),m);
   return(x);
END;
function rndint (r in number) return number is
x number;
BEGIN
   a:=mod(mult(a,b)+1,m);
   x:=trunc((trunc(a/m1)*r)/m1);
   return(x);
END;
function rndflt return number is
x number;
BEGIN
   a:=mod(mult(a,b)+1,m);
   x:=a/m;
   return(x);
END;
BEGIN
--   the_date:=sysdate;
--   days:=to_number(to_char(the_date, 'J'));
--   secs:=to_number(to_char(the_date, 'SSSSS'));
--   a:=days*24*3600+secs;
select hsecs into a from v$timer;
END;
/

