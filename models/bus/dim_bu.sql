{{
    config(
        materialized = 'view'
    )
}}

{{ model_generate_dim_scd ( var("bu_key"), ref('historized_bu') ) }}