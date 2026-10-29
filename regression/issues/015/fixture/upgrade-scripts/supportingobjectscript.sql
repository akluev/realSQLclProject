begin
 for rec in (select 1 x from dual) loop
  dbms_output.put_line ('Test');
 end loop;
end;
/ 