{% snapshot historized_user_rls %}

{{
    config (
      unique_key    = "user_email + authorized_bu_code + authorized_customer_name + authorized_item_type",
      strategy      = 'check',
      target_schema = 'scd',
      check_cols    = 'all',
      invalidate_hard_deletes = True
    )
}}

{# To be tested in more details #}

SELECT
  user_email
  , authorized_bu_code
  , authorized_customer_name
  , authorized_item_type
  
FROM {{ ref("user_rls") }}

{% endsnapshot %}