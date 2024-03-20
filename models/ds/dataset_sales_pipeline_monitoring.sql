{{ dbt_utils.union_relations (
    relations = [
        ref('dataset_sales_pipeline'),
        ref('prep_budget_for_union')
        ],
    exclude=["_dbt_source_relation"]
    )
}}