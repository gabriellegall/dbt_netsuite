{{
    config (
        materialized = 'view'
    )
}}

{{ dbt_utils.union_relations (
    relations = [
        ref('fact_sales_pipeline'),
        ref('prep_budget_for_union')
        ],
    exclude=["_dbt_source_relation"]
    )
}}