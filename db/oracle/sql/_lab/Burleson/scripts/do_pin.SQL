/*  */
create or replace procedure do_pin as
--
CURSOR get_packs IS
SELECT 
	object_name 
FROM 
	revealnet_kept_objects;
--
pack_name VARCHAR2(64);
--
BEGIN
	OPEN get_packs;
	LOOP
		FETCH get_packs INTO pack_name;
		EXIT WHEN get_packs%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE('Pinning '||pack_name);
		DBMS_SHARED_POOL.KEEP(pack_name);
	END LOOP;
	CLOSE get_packs;
END do_pin;
/
