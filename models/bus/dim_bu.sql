{{
    config(
        materialized = 'view'
    )
}}

{{ model_generate_dim_scd ( var("business_unit_key"), ref('historized_bu') ) }}