{% snapshot item_snapshot %}

{{
    config(
      unique_key    = 'item_nsid',
      strategy      = 'check',
      target_schema = 'scd',
      check_cols    = ['item_name']
    )
}}

select * from {{ ref('item') }}

{% endsnapshot %}