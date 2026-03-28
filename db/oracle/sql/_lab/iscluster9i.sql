BEGIN
  IF dbms_utility.is_cluster_database THEN
      dbms_output.put_line('Running in SHARED/RAC mode.');
  ELSE
      dbms_output.put_line('Running in EXCLUSIVE SERVER mode.');
  END IF;
END;
/