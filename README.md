### Business context

The client is a company working in the Cosmetic industry.
Following a successful implementation of the ERP NetSuite, the CEO wants to construct a monitoring BI ecosystem.
While NetSuite offers some reporting capabilities, the client is limited with NetSuite because :
- Some transformations are impossible to do in NetSuite (e.g. perform several joins throughout the model)
- Some external data should be integrated (mostly Excel files in this project)
...

### Business requirements

- The first use case identified by the client is a monitoring of the sales pipeline, which is defined by the invoices, sales orders and opportunities transactions.
- While it can be useful to analyze the sales pipeline alone, the client wants to set some business objectives - which are recorded under a budget Excel file.
    - The budget Excel file matches with some, but not all, of the dimension attributes of NetSuite that are applicable to the sales pipeline:
    - The client wants to relate the budget with the business unit dimension using the bu_code key - which is not the primary key for the dimension in NetSuite
    - The client wants to record the customer_name inside the budget file and is aware that no join will be possible with the NetSuite customer dimension since the match is too fuzzy 

### Data quality requirements