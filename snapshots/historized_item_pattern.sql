{% snapshot historized_item_pattern %}

{{
    config(
      unique_key    = var("item_pattern_key"),
      strategy      = 'check',
      target_schema = 'scd',
      check_cols    = 'all'
    )
}}

SELECT
  item_pattern_nsid
  , item_pattern
FROM {{ ref('item_pattern') }} it

{% endsnapshot %}