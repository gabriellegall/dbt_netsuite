{% snapshot historized_item %}

{{
    config(
      unique_key    = 'item_nsid',
      strategy      = 'check',
      target_schema = 'scd',
      check_cols    = ['item_name']
    )
}}

SELECT
  *
FROM {{ ref('item') }}

{% endsnapshot %}