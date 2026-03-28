/*  */
--
-- Triggers to enforce either -- or relationship between
-- customer_sites, bbs_new_customer and their dependent tables.
-- Update trigger on bbs_earnings_info also enforces cascade update
-- to its dependent tables based on entries in the bbs_update_tables
-- table. Created by Mike Ault 1/24/97 rev 2.0
--
create trigger cnetI_BBS_AE after INSERT on BBS_AE for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'INSERT into "BBS_AE" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 end if;
end;
/
create trigger cnetU_BBS_AE after UPDATE on BBS_AE for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'UPDATE of "BBS_AE" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 end if;
end;
/
--
--
create trigger cnetI_USERS after INSERT on USERS for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'INSERT into "USERS" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 end if;
end;
/
create trigger cnetU_USERS after UPDATE on USERS for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'UPDATE of "USERS" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 end if;
end;
/
--
--
create trigger cnetI_BBS_INTERACTION_LOG after INSERT on BBS_INTERACTION_LOG for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'INSERT into "BBS_INTERACTION_LOG" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 end if;
end;
/
create trigger cnetU_BBS_INTERACTION_LOG after UPDATE on BBS_INTERACTION_LOG for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'UPDATE of "BBS_INTERACTION_LOG" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 end if;
end;
/
--
--
create trigger cnetI_BBS_EARNINGS_INFO after INSERT on BBS_EARNINGS_INFO for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'INSERT into "BBS_EARNINGS_INFO" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 end if;
end;
/
create trigger cnetU_BBS_EARNINGS_INFO after UPDATE on BBS_EARNINGS_INFO for each row
declare
 numrows INTEGER;
 numrows2 INTEGER;
begin
 select 
      count(1) into numrows
 from 
      bbs_new_customer
 where
      :new.site_id = bbs_new_customer.site_id;
 select 
      count(1) into numrows2
 from 
      customer_sites
 where
      :new.site_id = customer_sites.site_id;
 if (numrows = 0 and numrows2 = 0)
 then
      raise_application_error(
        -20001,
        'UPDATE of "BBS_INTERACTION_LOG" failed. site_id not in "BBS_NEW_CUSTOMER" or "CUSTOMER_SITES".'
      );
 else
      begin
	cnet.update_tables('BBS_EARNINGS_INFO',:old.site_id,:new.site_id);
      end;
 end if;
end;
/

