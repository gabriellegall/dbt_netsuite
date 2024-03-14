{{
    config (
        materialized = 'view'
    )
}}

{{ model_generate_dim_scd ( var("customer_key"), ref('historized_customer') ) }}