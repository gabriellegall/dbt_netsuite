{{
    config(
        materialized = 'view'
    )
}}

{{ generate_dim_scd('item_nsid', ref('historized_item')) }}