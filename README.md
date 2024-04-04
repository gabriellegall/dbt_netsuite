# Business context

The client is a company working in the Cosmetic industry.
Following a successful implementation of the ERP NetSuite, the CEO wants to construct a BI ecosystem and leverage this new data source.
While NetSuite offers some reporting capabilities, the client is limited with NetSuite alone because :
- Some transformations are impossible to do in NetSuite (e.g. perform several joins throughout the model)
- Some external data should be integrated (mostly Excel files in this project)
...

# Business requirements
The first use case identified by the client is a monitoring of the sales pipeline, which is defined by the invoices, sales orders and opportunities transaction types in NetSuite.

## Input sources

### Transactions
In NetSuite, transactions are recorded at two levels :
1. transaction, which can be understood as the document header.
2. transaction_line, which can be understood as the document details.

### Dimension
There are several NetSuite dimension that are relevant in the context of the sales pipeline analysis (and more) :
- Customer
- Item
- Business Unit (aka. 'Subsidiary' in NetSuite)

### Row-level-security (RLS)
Datasets are expected to be restricted to the scope of each authorized user - at a row level.
RLS is provided in the form of an Excel file and containing several dimensions to be used for each user email : bu_code, customer_name and item_type.
The Excel file is expected to contain multivalued attributes separated by a comma ','.
The security that should be enforced is the intersection of all conditions/dimensions.
However, if another record is provided for the same user email, the two sets of conditions to be additive.

### Budget
To monitor the performance of the sales pipeline, a budget file is provided by the client's finance team in the form of an Excel file. 
Because the data entry is made by the finance team, the budget Excel file matches with some, but not all, of the dimension attributes of NetSuite listed previously. Namely :
- The finance team only provides the customer_name, and the client is aware that no relation will be possible with the NetSuite customer dimension since the join is too fuzzy.
- No budget is recorded at an item level.
- The finance team only provides the bu_code, which is not the expected foreign key to the Business Unit dimension. The expected key is the bu_nsid, but the client says that the bu_code is an acceptable alternative key.
Overall, the consequence is that the budget data will return NULL if non applicable dimension attributes are ever used as filters inside the BI tool.

## FX rates
The existing NetSuite transactional rate is used to convert foreign amounts to the amounts in business unit currency. However, the client wants to then convert each business unit amount to USD and EUR using an external Excel file provided by the treasury department. The FX rates file provided by the treasury department is at a year-month level, and the client says that the rate to be used depends on the year-month of the transaction date. If no rate is available at the transaction date, then the latest rate available for the given currency should be used.
The client says that amounts will always require to be reported in USD currency, but the reporting in EUR currency may change in the future.

## Historization

## Data volume & performance

## Modilarity

# Data quality requirements