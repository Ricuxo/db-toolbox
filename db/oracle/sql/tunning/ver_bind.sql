---ver bind variables
select * from table (dbms_xplan.display_cursor('[c4a8sy1u9vqa2]',[0], format => 'TYPICAL +PEEKED_BINDS'));