{% snapshot historized_item %}

{{
    config(
      unique_key    = var("item_key"),
      strategy      = 'check',
      target_schema = 'scd',
      check_cols    = 'all'
    )
}}

SELECT
  it.item_nsid
  , it.item_name
  , it.item_code
  , it.item_type
  , it.project_code
  , it.item_category_nsid
  , it.item_pattern_nsid
FROM {{ ref('item') }} it

{% endsnapshot %}