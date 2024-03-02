SELECT 
    t.transaction_nsid
    , tl.transaction_line_nsid
    , t.transaction_type
    , t.transaction_number
    , t.transaction_date

FROM {{ ref('transaction') }} t
    LEFT OUTER JOIN {{ ref('transactionline') }} tl
    ON t.transaction_nsid = tl.transaction_nsid