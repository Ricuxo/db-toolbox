To enable UTL_SMTP in the database java must be enabled run

$ORACLE_HOME/javavm/install/initjvm.sql
$ORACLE_HOME/javavm/install/init_jis.sql
$ORACLE_HOME/rdbms/admin/initplsj.sql


create or replace procedure pr_envia_email (
  p_remetente      varchar2(50); -- usar formato "<e-mail>"
  p_destinatario   varchar2(50); -- usar formato "<e-mail>"
  p_assunto        varchar2(50);
  p_mensagem       varchar2(80);
  p_mailhost       varchar2(15); -- IP do SMTP Server
  p_dominio        varchar2(50); -- Domínio na web
  p_username_      varchar2(50); -- Endereço de e-mail para autenticacao no
SMTP Server
  p_password_      varchar2(50); -- Senha para autenticacao no SMTP Server
) as
  v_mail_conn      utl_smtp.connection;
  v_mail_reply     utl_smtp.replies;
  crlf             varchar2(2) := chr(13)||chr(10);
  v_corpo_mensagem varchar2(2000);
begin
  v_corpo_mensagem := 'Date: ' ||
    TO_CHAR(SYSDATE,'dd Mon yy hh24:mi:ss')||crlf||
    'From: ' ||p_remetente||crlf||
    'To: ' ||p_destinatario||crlf||
    'Subject: ' ||p_assunto ||crlf||
    p_mensagem;
  v_mail_conn := utl_smtp.open_connection(p_mailhost,25);
  utl_smtp.ehlo (v_mail_conn, p_dominio);
  utl_smtp.command (v_mail_conn, 'AUTH LOGIN');
  utl_smtp.command (v_mail_conn, utl_raw.cast_to_varchar2(
    utl_encode.base64_encode(utl_raw.cast_to_raw(p_username_))));
  utl_smtp.command (v_mail_conn, utl_raw.cast_to_varchar2(
    utl_encode.base64_encode(utl_raw.cast_to_raw(p_password_))));
  utl_smtp.mail (v_mail_conn, p_remetente);
  utl_smtp.rcpt (v_mail_conn, p_destinatario);
  utl_smtp.data (v_mail_conn, v_corpo_mensagem);
  utl_smtp.quit (v_mail_conn);
exception
  when others then
    raise_application_error(-20002,'não foi possivel enviar o
email!!!'||sqlerrm);
end;
/
