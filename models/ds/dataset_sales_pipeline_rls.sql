{{
    config (
        materialized = 'view'
    )
}}

-- depends_on: {{ ref('prep_rls_normalize') }}
{{ generate_cte_rows(ref("dataset_sales_pipeline"), "all_conditions") }}