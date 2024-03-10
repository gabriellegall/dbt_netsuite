{% snapshot historized_bu %}

{{
    config(
      unique_key    = var("business_unit_key")
      , strategy      = 'check'
      , target_schema = 'scd'
      , check_cols    = 'all'
    )
}}

SELECT
  bu.bu_nsid
  , bu.bu_code
  , bu.bu_country_code
FROM {{ ref('subsidiary') }} bu

{% endsnapshot %}