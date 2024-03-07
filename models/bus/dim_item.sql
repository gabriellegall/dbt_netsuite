{{
    config(
        materialized = 'view'
    )
}}

{{ model_generate_dim_scd('item_nsid', ref('historized_item')) }}