/*  */
create or replace FUNCTION translate_param( p_param_name IN v$parameter.name%TYPE )
RETURN NUMBER
AS

  l_multiplier  NUMBER;
  l_raw_value  NUMBER;
  l_final_value  NUMBER;
  
  numeric_overflow  EXCEPTION;
  PRAGMA  exception_init(numeric_overflow, -1426);

BEGIN

  SELECT decode( ltrim(upper(value),'0123456789'),
                 'G',  1024*1024*1024,
                 'M',  1024*1024,
                 'K',  1024,
                 NULL, 1,
                       0 ) AS multiplier,
         rtrim(upper(value), 'KMG') AS raw_value
    INTO l_multiplier,
         l_raw_value
    FROM v$parameter
   WHERE name = p_param_name;

  l_final_value := l_multiplier * l_raw_value;

  RETURN l_final_value;

EXCEPTION
  WHEN no_data_found OR
       value_error THEN
    RETURN to_number(NULL);
  WHEN others THEN
    RAISE;

END translate_param;
/

