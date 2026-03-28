/*  */

HM.LKP_SAP_BROKER
HM.DIS_SAP_BROKER
HM.LKP_SAP_PRODUCT

CREATE TABLE hm.stg_sap_broker (
data_rec_tx VARCHAR2(2000)
)
PCTFREE 15   PCTUSED 80
INITRANS 1 MAXTRANS 255
TABLESPACE HMDATA
STORAGE (
INITIAL 106496 NEXT 122880
FREELISTS 1 FREELIST GROUPS 255
MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0)
/

CREATE TABLE hm.lkp_sap_broker (
sale_org_cd VARCHAR2(4) constraint ck_LKP_SAP_BROKER_1 NOT NULL
,dstrb_chnl_cd VARCHAR2(2) constraint ck_LKP_SAP_BROKER_2 NOT NULL
,div_cd VARCHAR2(2) constraint ck_LKP_SAP_BROKER_3 NOT NULL
,cust_grp_cd VARCHAR2(2) constraint ck_LKP_SAP_BROKER_4 NOT NULL
,sale_dstrc_cd VARCHAR2(6) constraint ck_LKP_SAP_BROKER_5 NOT NULL
,matl_price_grp_cd VARCHAR2(2) constraint ck_LKP_SAP_BROKER_6 NOT NULL
,valid_from_dt DATE constraint ck_LKP_SAP_BROKER_7 NOT NULL
,valid_to_dt DATE
,broker_nr VARCHAR2(10)
,sale_emp_nr VARCHAR2(8)
,creat_ts DATE
,updt_ts DATE
,user_nm VARCHAR2(30)
)
PCTFREE 15   PCTUSED 80
INITRANS 1 MAXTRANS 255
TABLESPACE HMDATA
STORAGE (
INITIAL 106496 NEXT 122880
FREELISTS 1 FREELIST GROUPS 255
MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0)
/

CREATE TABLE dis_sap_broker (
data_rec_tx VARCHAR2(2000)
,rjt_cd VARCHAR2(500)
,creat_ts DATE
,user_nm VARCHAR2(30)
)
PCTFREE 15   PCTUSED 80
INITRANS 1 MAXTRANS 255
TABLESPACE HMDATA
STORAGE (
INITIAL 106496 NEXT 122880
FREELISTS 1 FREELIST GROUPS 255
MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0)
/

CREATE TABLE lkp_sap_product (
sku VARCHAR2(18) constraint ck_LKP_SAP_PRODUCT_1 NOT NULL
,sku_description VARCHAR2(100)
,dist_channel VARCHAR2(2) constraint ck_LKP_SAP_PRODUCT_2 NOT NULL
,division VARCHAR2(2) constraint ck_LKP_SAP_PRODUCT_3 NOT NULL
,sales_org VARCHAR2(4) constraint ck_LKP_SAP_PRODUCT_4 NOT NULL
,grade VARCHAR2(18)
,color VARCHAR2(4)
,basis_weight VARCHAR2(5)
,size_category VARCHAR2(1)
,matl_grp VARCHAR2(9)
,matl_price_grp VARCHAR2(2)
,matl_price_grp3 VARCHAR2(3)
,matl_type VARCHAR2(4)
,commission_grp VARCHAR2(2)
,unit_of_weight VARCHAR2(3)
,base_unit_of_meas VARCHAR2(3)
,upc VARCHAR2(18)
,sku_less_suffix VARCHAR2(6)
,old_matl_num VARCHAR2(18)
,air_scent VARCHAR2(4)
,air_scent_description VARCHAR2(40)
,basis_weight_factor VARCHAR2(6)
,basis_weight_size_code VARCHAR2(2)
,benchmark_grade VARCHAR2(3)
,brand VARCHAR2(10)
,brand_family VARCHAR2(8)
,brand_grouping VARCHAR2(5)
,brand_label VARCHAR2(5)
,brand_type VARCHAR2(3)
,category VARCHAR2(3)
,category_grp VARCHAR2(4)
,category_segment VARCHAR2(4)
,color_grp VARCHAR2(4)
,color_grp_summ VARCHAR2(1)
,dispenser_finish VARCHAR2(4)
,finished_paper_color VARCHAR2(4)
,gp_or_vendor_sourced VARCHAR2(3)
,grade_grp VARCHAR2(3)
,inc_excl_grp VARCHAR2(4)
,market_grp VARCHAR2(3)
,market_grp_summ VARCHAR2(2)
,market_view VARCHAR2(3)
,owning_bus_grp VARCHAR2(2)
,planning_grp VARCHAR2(6)
,ppd_pack_config VARCHAR2(3)
,paper_nonpaper VARCHAR2(3)
,ppd_sheet_count VARCHAR2(6)
,ppd_sheet_length VARCHAR2(9)
,ppd_sheet_width VARCHAR2(9)
,prod_grp_1 VARCHAR2(4)
,prod_grp_2 VARCHAR2(3)
,roll_finish_unit VARCHAR2(5)
,sheet_finish_unit VARCHAR2(5)
,soap_formula VARCHAR2(4)
,afpa_matl_code VARCHAR2(18)
,tissue_ply VARCHAR2(1)
,roll_width VARCHAR2(7)
,parent_roll_core VARCHAR2(6)
,parent_roll_diam VARCHAR2(4)
,paper_specification VARCHAR2(5)
,sru_factor NUMBER(15,3)
,equivalized_factor NUMBER(15,3)
,cube_factor NUMBER(15,3)
,private_label_code VARCHAR2(30)
,dw_business_segment_code VARCHAR2(30)
,financial_category_code VARCHAR2(30)
,create_date DATE
,update_date DATE
,username VARCHAR2(30)
)
PCTFREE 10   PCTUSED 85
INITRANS 1 MAXTRANS 255
TABLESPACE HMDATA
STORAGE (
INITIAL 1048576 NEXT 1048576
FREELISTS 1 FREELIST GROUPS 255
MINEXTENTS 1 MAXEXTENTS 2147483645 PCTINCREASE 0)
/

ALTER TABLE LKP_SAP_PRODUCT add constraint LKP_SAP_PRODUCT_PK primary key (
SKU,
SALES_ORG,
DIST_CHANNEL
);

ALTER TABLE LKP_SAP_BROKER add constraint LKP_SAP_BROKER_PK primary key (
SALE_ORG_CD,
DSTRB_CHNL_CD,
DIV_CD,
SALE_DSTRC_CD,
VALID_FROM_DT,
MATL_PRICE_GRP_CD,
CUST_GRP_CD
);
