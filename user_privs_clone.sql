Enter value for new_user: PIX_PAYIN
Enter value for cur_user: PIX_PARTNER
create user PIX_PAYIN identified by values ''  default tablespace PIX_PARTNER temporary tablespace T
EMP profile DEFAULT;

grant RESOURCE to PIX_PAYIN;
grant CREATE SESSION to PIX_PAYIN;
alter user PIX_PARTNER quota UNLIMITED on PIX_PARTNER;
alter user PIX_PAYIN default role RESOURCE;
