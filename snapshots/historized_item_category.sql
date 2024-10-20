{% snapshot historized_item_category %}

{{
    config(
      unique_key    = var("item_category_key"),
      strategy      = 'check',
      target_schema = 'scd',
      check_cols    = 'all'
    )
}}

SELECT
  item_category_nsid
  , item_category
  , item_sub_category
FROM {{ ref('item_category') }}

{% endsnapshot %}