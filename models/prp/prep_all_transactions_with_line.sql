{{
    config (
        materialized = 'ephemeral'
    )
}}

{{ dbt_utils.union_relations (
    relations = [
                ref('prep_transaction_with_lines_for_union'),
                ref('historized_transaction_with_line')
                ]
    ) }}