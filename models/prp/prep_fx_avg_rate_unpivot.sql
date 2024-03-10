{{
    config (
        materialized = 'view'
    )
}}

{{
    dbt_utils.unpivot (
        relation = ref("fx_avg_rate"),
        cast_to = "float",
        exclude = ['original_currency','target_currency'],
        field_name = "closing_date",
        value_name = "fx_rate"
    )
}}