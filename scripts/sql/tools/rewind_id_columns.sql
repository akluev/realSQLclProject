set serveroutput on

purge recyclebin
/
select *
    from   user_tab_identity_cols
    where table_name not like 'BIN$%/%==%'
    order  by table_name
/    



-- Sync all identity-backed sequences to MAX(column)+1
set serveroutput on

---- ID Columns 

declare
  l_sql        varchar2(4000);
  l_max_val    number;
  l_next_seq   number;
  l_delta      number;
  l_dummy      number;
begin
  for r in (
    select table_name, column_name, sequence_name, generation_type
    from   user_tab_identity_cols
    where table_name not like 'BIN$%/%==%'
    order  by table_name
  )
  loop
    -- 1) compute desired next value = max(col)+1
    l_sql := 'select nvl(max('||dbms_assert.enquote_name(r.column_name,false)||'),0) + 1 from '
             || dbms_assert.enquote_name(r.table_name,false);
    execute immediate l_sql into l_max_val;

    -- 2) current next value from the sequence
     execute immediate 'select '||r.sequence_name||'.nextval' into l_next_seq;


    l_delta := l_max_val - l_next_seq;

    if l_delta <= 0 then
      dbms_output.put_line(r.table_name||'.'||r.column_name||' ok (next='||l_next_seq||')');
    else
      -- Allow movement in either direction (up or down)
      -- (Optional) ensure we won’t hit MINVALUE going backwards
      begin
        l_sql := apex_string.format('alter table %s modify (%s generated %s as identity (minvalue 0))' , r.table_name, r.column_name, r.generation_type ) ;
        execute immediate l_sql;
      exception 
       when others then 
        dbms_output.put_line(sqlerrm ); 
        dbms_output.put_line(l_sql ); 
      end;


       l_sql := apex_string.format('alter table %s modify (%s generated %s as identity (increment by %s ))' , r.table_name, r.column_name, r.generation_type, l_delta ) ;
       execute immediate l_sql;
 
      -- Advance exactly once to “apply” the increment step
      execute immediate 'select '||r.sequence_name||'.nextval' into l_dummy;

      -- Restore normal increment
       l_sql := apex_string.format('alter table %s modify (%s generated %s as identity (increment by %s ))' , r.table_name, r.column_name, r.generation_type, 1 ) ;
       execute immediate l_sql;


      -- show new position
      select last_number into l_next_seq
      from   user_sequences
      where  sequence_name = r.sequence_name;

      dbms_output.put_line(r.table_name||'.'||r.column_name||
                           ' synced to next='||l_next_seq||' (was delta='||l_delta||','||'max='||l_max_val||')');
    end if;
  end loop;
end;
/

--- Other Sequences 


declare
  l_sql        varchar2(4000);
  l_max_val    number;
  l_next_seq   number;
  l_delta      number;
  l_dummy      number;
begin
  for r in (
        select cc.*  , sequence_name
         from user_constraints c, 
         user_cons_columns cc,   
         user_sequences s
         where c.constraint_type ='P'
        and c.constraint_name = cc.constraint_name
        and cc.position =1 
        and s.sequence_name = c.table_name||'_SEQ'
        order by c.table_name
  )
  loop
    -- 1) compute desired next value = max(col)+1
    l_sql := 'select nvl(max('||dbms_assert.enquote_name(r.column_name,false)||'),0) + 1 from '
             || dbms_assert.enquote_name(r.table_name,false);
    execute immediate l_sql into l_max_val;

    -- 2) current next value from the sequence
     execute immediate 'select '||r.sequence_name||'.nextval' into l_next_seq;


    l_delta := l_max_val - l_next_seq;

    if l_delta <= 0 then
      dbms_output.put_line(r.table_name||'.'||r.column_name||' ok (next='||l_next_seq||')');
    else
      -- Allow movement in either direction (up or down)
      -- (Optional) ensure we won’t hit MINVALUE going backwards
      begin
        l_sql :=   'alter sequence '||r.sequence_name||' minvalue 0'; 
        execute immediate l_sql;
      exception 
       when others then 
        dbms_output.put_line(sqlerrm ); 
        dbms_output.put_line(l_sql ); 
      end;


       l_sql := 'alter sequence '||r.sequence_name||' increment by '||l_delta;
       execute immediate l_sql;
 
      -- Advance exactly once to “apply” the increment step
      execute immediate 'select '||r.sequence_name||'.nextval' into l_dummy;

      -- Restore normal increment
       l_sql := 'alter sequence '||r.sequence_name||' increment by 1';
       execute immediate l_sql;


      -- show new position
      select last_number into l_next_seq
      from   user_sequences
      where  sequence_name = r.sequence_name;

      dbms_output.put_line(r.table_name||'.'||r.column_name||
                           ' synced to next='||l_next_seq||' (was delta='||l_delta||','||'max='||l_max_val||')');
    end if;
  end loop;
end;
/

