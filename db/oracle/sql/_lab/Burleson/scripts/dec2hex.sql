/*  */
/* Formatted by PL/Formatter v.1.1.8 on 2011/11/25 12:56  (12:56 AM) */


CREATE OR REPLACE PROCEDURE dec2hex (in_num IN NUMBER, out_hex OUT VARCHAR2)
IS
   TYPE vc2tab_type IS TABLE OF VARCHAR2(1)
      INDEX BY BINARY_INTEGER;

   hextab                        vc2tab_type;
   v_num                         NUMBER;
   v_hex                         VARCHAR2(200);

/*
Author: Jonas Nordstrom 
*/
BEGIN
   IF in_num IS NULL THEN RETURN NULL; END IF;   

   hextab  (0) := '0';
   hextab  (1) := '1';
   hextab  (2) := '2';
   hextab  (3) := '3';
   hextab  (4) := '4';
   hextab  (5) := '5';
   hextab  (6) := '6';
   hextab  (7) := '7';
   hextab  (8) := '8';
   hextab  (9) := '9';
   hextab  (10) := 'A';
   hextab  (11) := 'B';
   hextab  (12) := 'C';
   hextab  (13) := 'D';
   hextab  (14) := 'E';
   hextab  (15) := 'F';
   v_num := in_num;

   WHILE v_num >= 16
   LOOP
      v_hex := hextab (MOD (v_num, 16)) || v_hex;
      v_num := TRUNC (v_num / 16);
   END LOOP;

   v_hex := hextab (MOD (v_num, 16)) || v_hex;
   out_hex := v_hex;
END;   -- dec2hex
/

CREATE OR REPLACE FUNCTION hextointeger (h VARCHAR2)
   RETURN PLS_INTEGER
IS
BEGIN
   IF NVL (LENGTH (h), 1) = 1
   THEN
      RETURN INSTR ('0123456789ABCDEF', h) - 1;
   ELSE
      RETURN 16 * hextointeger (SUBSTR (h, 1, LENGTH (h) - 1)) +
             INSTR ('0123456789ABCDEF', SUBSTR (h, -1)) -
             1;
   END IF;
END hextointeger;
/

CREATE OR REPLACE FUNCTION integertohex (n pls_integer)
   RETURN VARCHAR2
IS
BEGIN
   IF n > 0
   THEN
      RETURN integertohex (TRUNC (n / 16)) ||
             SUBSTR ('0123456789ABCDEF', MOD (n, 16) + 1, 1);
   ELSE
      RETURN NULL;
   END IF;
END integertohex;
/





