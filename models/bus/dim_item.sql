{{
    config(
        materialized = 'view'
        , enabled = true
    )
}}

{{ generate_dim_scd('item_nsid', ref('historized_item')) }}