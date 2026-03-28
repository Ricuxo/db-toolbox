COLUMN host FORMAT A100
COLUMN acl FORMAT A30

SELECT host, lower_port, upper_port, acl
FROM   dba_network_acls;


set lines 200 
COL ACL_OWNER FOR A12 
COL ACL FOR A67 
COL HOST FOR A34 
col PRINCIPAL for a20 
col PRIVILEGE for a13 
select ACL_OWNER,ACL,HOST,LOWER_PORT,UPPER_PORT 
FROM dba_network_acls; 
select ACL_OWNER,ACL,PRINCIPAL,PRIVILEGE from dba_network_acl_privileges; 



COLUMN acl FORMAT A30 
COLUMN principal FORMAT A30  
SELECT acl,principal,privilege,is_grant,TO_CHAR(start_date, 'DD-MON-YYYY') AS start_date, TO_CHAR(end_date, 'DD-MON-YYYY') AS end_date 
FROM dba_network_acl_privileges; 




DECLARE
  l_url            VARCHAR2(50) := 'https://style-plm.hml.ceabr.io';
  l_http_request   UTL_HTTP.req;
  l_http_response  UTL_HTTP.resp;
BEGIN
  -- Make a HTTP request and get the response.
  l_http_request  := UTL_HTTP.begin_request(l_url);
  l_http_response := UTL_HTTP.get_response(l_http_request);
  UTL_HTTP.end_response(l_http_response);
END;
/



CREATE OR REPLACE PROCEDURE show_html_from_url (
  p_url  IN  VARCHAR2,
  p_username IN VARCHAR2 DEFAULT NULL,
  p_password IN VARCHAR2 DEFAULT NULL
) AS
  l_http_request   UTL_HTTP.req;
  l_http_response  UTL_HTTP.resp;
  l_text           VARCHAR2(32767);
BEGIN
  -- Make a HTTP request and get the response.
  l_http_request  := UTL_HTTP.begin_request(p_url);

  -- Use basic authentication if required.
  IF p_username IS NOT NULL and p_password IS NOT NULL THEN
    UTL_HTTP.set_authentication(l_http_request, p_username, p_password);
  END IF;

  l_http_response := UTL_HTTP.get_response(l_http_request);

  -- Loop through the response.
  BEGIN
    LOOP
      UTL_HTTP.read_text(l_http_response, l_text, 32766);
      DBMS_OUTPUT.put_line (l_text);
    END LOOP;
  EXCEPTION
    WHEN UTL_HTTP.end_of_body THEN
      UTL_HTTP.end_response(l_http_response);
  END;
EXCEPTION
  WHEN OTHERS THEN
    UTL_HTTP.end_response(l_http_response);
    RAISE;
END show_html_from_url;
/


SET SERVEROUTPUT ON
EXEC show_html_from_url('https://style-plm.hml.ceabr.io/styles/');


SET SERVEROUTPUT ON
EXEC UTL_HTTP.set_wallet('file:/u01/app/oracle/admin/rfrisut5/wallet', NULL);
EXEC show_html_from_url('https://style-plm.ceabr.io/styles/C679491');