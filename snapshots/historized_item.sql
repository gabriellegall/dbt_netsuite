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
  , it_cat.item_category
  , it_cat.item_sub_category
  , it_pat.item_pattern
  
FROM {{ ref('item') }} it
  LEFT OUTER JOIN {{ ref('item_category') }} it_cat 
    ON it.item_category_nsid = it_cat.item_category_nsid
  LEFT OUTER JOIN {{ ref('item_pattern') }} it_pat
    ON it.item_pattern_nsid = it_pat.item_pattern_nsid

{% endsnapshot %}