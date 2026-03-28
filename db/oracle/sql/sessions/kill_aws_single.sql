begin rdsadmin.rdsadmin_util.kill(sid    => &sid, 
        serial => &serial_number,
        method => 'IMMEDIATE');
end;
/