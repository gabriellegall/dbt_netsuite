{{
    config (
        materialized = 'view'
    )
}}

-- depends_on: {{ ref('prep_rls_normalize') }}
{{ model_generate_dataset_rls(ref("dataset_sales_pipeline"), "customer_bu_item", "pk_" ~ var("all_transactions_with_line_key")) }}