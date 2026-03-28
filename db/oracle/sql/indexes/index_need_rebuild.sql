--The following script can be used to determine which indexes would benefit from a rebuild, 
-- how much they will shrink by (assuming 8k block size and 10% pctfree), 
-- results ordered by severity.
--
-- Ex de saida
--
-- INDEX_NAME                 PERCENT   STATUS
-- -------------------------- -------   ---------------------
-- TIM_OCUPACAO_MSAN_INDEX1   33        candidate for rebuild
-- TEMP_NODE_PORT_1IX         39        candidate for rebuild
--
--
col table_name for a30
col index_name for a30
col owner for a30
set lines 500
select a.*, round(index_leaf_estimate_if_rebuilt/current_leaf_blocks*100) percent, case when index_leaf_estimate_if_rebuilt/current_leaf_blocks < 0.5 then 'candidate for rebuild' end status
from
(
select owner,table_name, index_name, current_leaf_blocks, round (100 / 90 * (ind_num_rows * (rowid_length + uniq_ind + 4) + sum((avg_col_len) * (tab_num_rows) ) ) / (8192 - 192) ) as index_leaf_estimate_if_rebuilt
from (
select tab.owner,tab.table_name, tab.num_rows tab_num_rows , decode(tab.partitioned,'YES',10,6) rowid_length , ind.index_name, ind.index_type, ind.num_rows ind_num_rows, ind.leaf_blocks as current_leaf_blocks,
decode(uniqueness,'UNIQUE',0,1) uniq_ind,ic.column_name as ind_column_name, tc.column_name , tc.avg_col_len
from dba_tables tab
join dba_indexes ind on ind.owner=tab.owner and ind.table_name=tab.table_name
join dba_ind_columns ic on ic.table_owner=tab.owner and ic.table_name=tab.table_name and ic.index_owner=tab.owner and ic.index_name=ind.index_name
join dba_tab_columns tc on tc.owner=tab.owner and tc.table_name=tab.table_name and tc.column_name=ic.column_name
where ind.leaf_blocks is not null and ind.leaf_blocks > 1000
) group by owner,table_name, index_name, current_leaf_blocks, ind_num_rows, uniq_ind, rowid_length
) a where index_leaf_estimate_if_rebuilt/current_leaf_blocks < 0.5
order by index_leaf_estimate_if_rebuilt/current_leaf_blocks;