{{
    config (
        materialized = 'view',
    )
}}

WITH historized_item AS (
  SELECT
    item_nsid
    , item_name
    , item_code
    , item_type
    , project_code
    , item_category_nsid
    , item_pattern_nsid
    , dbt_scd_id
    , dbt_valid_from
    , COALESCE(dbt_valid_to, CAST('{{ var("future_proof_date") }}' AS DATETIME2)) AS dbt_valid_to
  FROM
    {{ ref('historized_item') }}
),

historized_item_pattern AS (
  SELECT
    item_pattern_nsid
    , item_pattern
    , dbt_scd_id
    , dbt_valid_from
    , COALESCE(dbt_valid_to, CAST('{{ var("future_proof_date") }}' AS DATETIME2)) AS dbt_valid_to
  FROM
    {{ ref('historized_item_pattern') }}
),

historized_item_category AS (
  SELECT
    item_category_nsid
    , item_category
    , item_sub_category
    , dbt_scd_id
    , dbt_valid_from
    , COALESCE(dbt_valid_to, CAST('{{ var("future_proof_date") }}' AS DATETIME2)) AS dbt_valid_to
  FROM
    {{ ref('historized_item_category') }}
),

{{
  model_trange_join(
    left_model='historized_item',
    left_fields=['item_nsid', 'item_name', 'item_code', 'item_type', 'project_code'],
    left_primary_key='item_nsid',
    right_models={
      'historized_item_category': {
        'fields': ['item_category', 'item_sub_category'],
        'left_on': 'item_category_nsid',
        'right_on': 'item_category_nsid',
      },
      'historized_item_pattern': {
        'fields': ['item_pattern'],
        'left_on': 'item_pattern_nsid',
        'right_on': 'item_pattern_nsid',
      }
    }
  )
}}

-- Conform to the dbt snapshot regular schema:
SELECT 
  item_nsid
  , item_name
  , item_code
  , item_type
  , project_code
  , item_category
  , item_sub_category
  , item_pattern
  , surrogate_key AS dbt_scd_id
  , NULL AS dbt_updated_at
  , valid_from_at AS dbt_valid_from
  , IIF(valid_to_at = CAST('{{ var("future_proof_date") }}' AS DATETIME2), NULL, valid_to_at) AS dbt_valid_to
FROM trange_final