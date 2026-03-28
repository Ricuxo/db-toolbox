### estima tamanho que indice tera a partir da tabela

variable used number
variable alloc number
col used for 999,999,999,999
col alloc for 999,999,999,999
set autoprint on
exec dbms_space.create_index_cost('create index integra.IDX_CONVERT_NONO_DIGITO_LINEA on integra.INT_ANAGRAFICA_LINEA (substr(CONVERT_MSISDN_NONO_DIGITO(MSISDN), 0, 20)) tablespace integra_indx_128m pctfree 10 initrans 2 maxtrans 255 storage ( initial 128m next 128m minextents 1 maxextents unlimited pctincrease 0 ) online NOLOGGING PARALLEL (DEGREE 32)', :used, :alloc );