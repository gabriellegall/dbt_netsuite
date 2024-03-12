{% snapshot historized_customer %}

{{
    config(
      unique_key    = var("customer_key")
      , strategy      = 'check'
      , target_schema = 'scd'
      , check_cols    = 'all'
    )
}}

SELECT
  cu.customer_nsid
  , cu.customer_name
  , cu.customer_tier
FROM {{ ref('customer') }} cu

{% endsnapshot %} 