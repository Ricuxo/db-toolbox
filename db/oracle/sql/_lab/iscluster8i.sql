BEGIN
  IF dbms_utility.is_parallel_server THEN
      dbms_output.put_line('Running in SHARED/PARALLEL mode.');
  ELSE
      dbms_output.put_line('Running in EXCLUSIVE SERVER mode.');
  END IF;
END;
/
