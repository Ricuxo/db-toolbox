select name, value from v$spparameter where isspecified = 'TRUE'
  minus
select name, value from v$parameter;