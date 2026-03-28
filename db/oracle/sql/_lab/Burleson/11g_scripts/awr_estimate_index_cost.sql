/*  */
declare
   u_bytes number;
   a_bytes number;
begin
   dbms_space.create_index_cost (
      ddl => 'create index stats$sysstat_idx on stats$sysstat '||
        '(value) tablespace sysaux',
      used_bytes => u_bytes,
      alloc_bytes => a_bytes
   );
   dbms_output.put_line ('Used Bytes      = '|| u_bytes);
   dbms_output.put_line ('Allocated Bytes = '|| a_bytes);
end;
/   
