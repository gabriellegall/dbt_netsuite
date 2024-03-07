{% snapshot historized_bu %}

{{
    config(
      unique_key    = var("bu_key"),
      strategy      = 'check',
      target_schema = 'scd',
      check_cols    = 'all',
      enabled       = true
    )
}}

SELECT
  bu.bu_nsid
  , bu.bu_code
FROM {{ ref('bu') }} bu

{% endsnapshot %}