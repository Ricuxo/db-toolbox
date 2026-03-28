/*  */
declare
true1 boolean;
false1 boolean;
null1 boolean;
answer1 boolean;
answer2 boolean;
answer3 boolean;
answer4 boolean;
x integer;
y integer;
z integer;
a integer;
begin
true1:=FALSE;
false1:=FALSE;
null1:=NULL;
price_increase(null1,true1,answer1);
price_increase(null1,false1,answer2);
price_increase(null1,null1,answer3);
price_increase(false1,false1,answer4);
if answer1 then 
   x:=1;
elsif not answer1 then 
   x:=2;
elsif answer1 is null then 
   x:=3;
end if;
if answer2 then 
  y:=1;
elsif not answer2 then 
  y:=2;
elsif answer2 is null then 
  y:=3;
end if;
if answer3 then 
  z:=1;
elsif not answer3 then 
  z:=2;
elsif answer3 is null then 
  z:=3;
end if;
if answer4 then 
   a:=1;
elsif not answer4 then 
   a:=2;
elsif answer4 is null then 
   a:=3;
end if;
dbms_output.put_line('null and true:'||to_char(x)||' null and false:'||to_char(y)||chr(10)||
' null and null:'||to_char(z)||' false and false:'||to_char(a));
end;
/
