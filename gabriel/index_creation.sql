
-- OPTIMIZATION #1
    -- MODEL : [transaction_with_line.sql]
    -- Pre-hook sub-tree cost (After) : 5,4
    -- Pre-hook sub-tree cost (After) : 87.7

CREATE UNIQUE CLUSTERED INDEX [clustered_transaction_with_line] ON [dwh].[transaction_with_line]
(
	[transaction_nsid] DESC,
	[transaction_line_nsid] DESC
);
CREATE NONCLUSTERED INDEX [nonclustered_transaction_with_line_modified_date] ON [dwh].[transaction_with_line]
(
	[transaction_last_modified_date] DESC,
	[transaction_line_last_modified_date] DESC
);

-- OPTIMIZATION #2
    -- MODEL : [fact_all_transactions_with_line.sql]
	-- Benefit too small for now, given the data volume
CREATE NONCLUSTERED INDEX [nonclustered_transaction_with_line_type_date] ON [dwh].[transaction_with_line]
(
	[transaction_type] ASC,
	[transaction_status] ASC,
	[transaction_date] ASC
);
CREATE NONCLUSTERED INDEX [nonclustered_historized_transaction_with_line_type_date] ON [dwh].[historized_transaction_with_line]
(
	[transaction_type] ASC,
	[transaction_status] ASC,
	[transaction_date] ASC
)

-- OPTIMIZATION #3
-- Using a table instead of a view for "dataset_sales_pipeline" changed the sub-tree cost of the RLS view :
	-- FROM : 3 451 680 
	-- TO 	: 208 061
	--> Materialize all the DS as tables