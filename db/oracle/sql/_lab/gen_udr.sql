BEGIN
   GEN_UDR_DDL.AlterTable (piosContextKey => 'DR_DOCUMENTS',piobdropcolumn => TRUE, piobExecute => TRUE);
      GEN_UDR_DDL.AlterTable (piosContextKey => 'DR_DOCUMENTS', piobExecute => TRUE);
   END;
/


BEGIN
   GEN_UDR_DDL.AlterTable (piosContextKey => 'BI_ACCOUNTS',piobdropcolumn => TRUE, piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'RTX_ERROR',piobdropcolumn => TRUE, piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'RTX_LT',piobdropcolumn => TRUE, piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'RTX_RAP',piobdropcolumn => TRUE, piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'RTX_ST',piobdropcolumn => TRUE, piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'RTX_TAP',piobdropcolumn => TRUE, piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'RTX_TAP_KEY',piobdropcolumn => TRUE, piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_KEY_HOME',piobdropcolumn => TRUE, piobExecute => TRUE);
   --GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_KEY_UDP',piobdropcolumn => TRUE, piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_KEY_VPLMN',piobdropcolumn => TRUE, piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_SUM_LT',piobdropcolumn => TRUE, piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_SUM_ST',piobdropcolumn => TRUE, piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'BCH_LT_APPEND',piobdropcolumn => TRUE, piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'BCH_ST_APPEND',piobdropcolumn => TRUE, piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_SUM_BCH_LT_APPEND',piobdropcolumn => TRUE, piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_SUM_BCH_ST_APPEND',piobdropcolumn => TRUE, piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'BI_ACCOUNTS', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'RTX_ERROR', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'RTX_LT', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'RTX_RAP', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'RTX_ST', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'RTX_TAP', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'RTX_TAP_KEY', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_KEY_HOME', piobExecute => TRUE);
   --GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_KEY_UDP', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_KEY_VPLMN', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_SUM_LT', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_SUM_ST', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'BCH_LT_APPEND', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'BCH_ST_APPEND', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_SUM_BCH_LT_APPEND', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_SUM_BCH_ST_APPEND', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_LT', piobExecute => TRUE);
   GEN_UDR_DDL.AlterTable (piosContextKey => 'UDR_ST', piobExecute => TRUE);
   GEN_UDR_DDL.CreateView_UDR_LT_ST(piobExecute => TRUE, piobAllObjects => TRUE);
   GEN_UDR_DDL.CreateView_BCH_UDR_LT_ST(piobExecute => TRUE, piobAllObjects => TRUE);
END;
/
