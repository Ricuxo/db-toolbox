/*Verifica os hints disponpiveis e a versao que eles foram introduzidos */

select name,version from v$sql_hint
where upper(name) like '%'||upper(nvl('&hint',name))||'%'
order by name;