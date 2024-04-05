# Business context

The client is a company working in the Cosmetic industry.
Following a successful implementation of the ERP NetSuite, the CEO wants to construct a BI ecosystem and leverage this new data source.
While NetSuite offers some reporting capabilities, the client is limited with NetSuite alone because :
- Some transformations are impossible to do in NetSuite (e.g. perform several joins throughout the model).
- Some external data should be integrated and cannot be recorded in NetSuite (e.g. budget, custom fx rates).
- Data historization (snapshotting) is impossible in NetSuite.
- BI users are not necessarily NetSuite users. They have a different user journeys and different row-level-security requirements.

# Business requirements
The first use case identified by the client is a monitoring of the sales pipeline, which is defined by the aggregation of invoices, 'open' sales orders and 'open' opportunities in NetSuite. The sales pipeline is basically the estimated landing sales for the year.
The client wants to use the annual budget as a performance objective for the sales and consolidate everything under a dataset which will be connected to a BI dashboard.
The dashboard will show the estimated landing compared to the objective and will enable the managers to monitor the sales team among each business unit, and for each client.

## Data sources

### Transactions
In NetSuite, all transactions are recorded at two levels :
1. transaction, which can be understood as the document header.
2. transaction_line, which can be understood as the document details.

Some document attributes are defined at a transaction level, while most financial attributes are captured at a transaction_line level.
There is a one-to-many relationship between transaction and transaction_line. 

### NetSuite Dimensions
There are several NetSuite dimension that are relevant in the context of the sales pipeline analysis (and more) :
- Customer
- Item
- Business Unit (aka. 'Subsidiary' in NetSuite)

### Date Dimension
The client has a fiscal calendar that is not starting in january, but in february.
This should be taken into consideration for all fields with time dependency ('current year', 'previous year', etc.)

### Row-level-security (RLS)
Datasets are expected to be restricted to the scope of each authorized user - at a row level.
RLS is provided in the form of an Excel file and containing several dimensions to be used for each user email : bu_code, customer_name and item_type.
The Excel file is expected to contain multivalued attributes separated by a comma ','.
The security that should be enforced is the intersection of all conditions/dimensions.
However, if another record is provided for the same user email, the two sets of conditions to be additive. This is a rare exception for some users who need to see the data of all their business unit + the data of some of their clients accross all business unit.

### Budget
To monitor the performance of the sales pipeline, a budget file is provided by the client's finance team in the form of an Excel file. 
Because the data entry is made by the finance team, the budget Excel file matches with some, but not all, of the dimension attributes of NetSuite listed previously. Namely :
- The finance team only provides the customer_name, and the client is aware that no relation will be possible with the NetSuite customer dimension since the join is too fuzzy.
- No budget is recorded at an item level.
- The finance team only provides the bu_code, which is not the expected foreign key to the Business Unit dimension. The expected key is the bu_nsid, but the client says that the bu_code is an acceptable alternative key.

Overall, the consequence is that the budget data will return NULL if non applicable dimension attributes are ever used as filters inside the BI tool.

### FX rates
The existing NetSuite transactional rate is used to convert foreign amounts to the amounts in business unit currency. However, the client wants to then convert each business unit amount to USD and EUR using an external Excel file provided by the treasury department. The FX rates file provided by the treasury department is at a year-month level, and the client says that the rate to be used depends on the year-month of the transaction date. If no rate is available at the transaction date, then the latest rate available for the given currency should be used.
The client says that the reporting will always be in USD, but the reporting in EUR currency may change in the future.

## Data processing

### Historization
- The client wants to historize the dimension attributes (SCD Type 2) to be able to track changes and report on both the live/current view and the historical view - at the time of the transaction date.
- The client wants to historize only some transaction types (invoices, sales order and opportunities) on a monthly basis. The client wants to limite data volume as much as possible to control costs and run-time performance. Thefore, a tracking of all transaction updates is not necessary, and a monthly snapshot is perfectly sufficient.

### Incremental load
As mentionned previously, the client wants to optimize performance as much as possible.
An incremental load of the transaction data is possible from NetSuite since both transaction_lines and transactions have field called last_modified_date which tracks the date of last update.
Several challenges are to be noted however :
- The date of last update at the transaction_line level and at the transaction level are sometimes inconsistent : a transaction_line can be updated without the transaction being updated, and vice-versa. To solve this challenge, the client agrees to perform DELETE + INSERT operation at a transaction level, based on the maximum date of last update. This is a conservative incremental scenario ensuring that all changes are captured.
- Deleted transaction are physically deleted from NetSuite transaction table (hard delete) and should therefore be deleted from the datawarehouse as well during the incremental update. An audit table called 'deleted_records' lists all transactions physically deleted from NetSuite and can be used to perform this operation. 
- Deleted transaction_lines are also physically deleted from NetSuite transaction_line table (hard delete) and should therefore be deleted from the datawarehouse as well during the incremental update. Since a deleted transaction_line automatically updates the date of last update at a transaction level, performing a DELETE + INSERT operation at a transaction level will automatically solve this problem.

# Risks and mitigation actions

## Incremental load discrepancy
Problem: One of the main risks is that the complex incremental update of the DWH table using the previously described incremental load is somehow flawed.
Solution: To control this risk, a test scenario has been designed to **control any row difference between the staging layer and the DWH layer using a hash of all columns and a full-outer join**.

## Changing schemas and maintenance
Problem: Since the ERP was recently implemented and is constantly evolving, several new fields will be integrated and the table schemas will evolve frequently.
Solution: To control this risk, **the schema of all tables is only defined once**.  Historized dimension tables are defined in the snapshots script, while transactions with transaction lines are defined under a single preparation script (under 'prep'). **Any change to those scripts will automatically propagate to the upper datawarehouse layer ('dwh'), business layers ('bus') and the dataset layers ('ds')**. This automatic propagation is managed using the '*' operator and the dbt_utils.star() function.

## Scope extension

## 
## Materialization