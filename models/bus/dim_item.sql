{{
    config (
        materialized = 'view'
    )
}}

{{ model_generate_dim_scd ( var("item_key"), ref('historized_item') ) }}