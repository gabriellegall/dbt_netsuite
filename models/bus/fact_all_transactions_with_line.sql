{{
    config (
        materialized = 'view'
    )
}}

WITH union_current_and_snapshot AS 
(
    {{ dbt_utils.union_relations (
        relations = [
                    ref('prep_transaction_with_lines_for_union'),
                    ref('historized_transaction_with_line')
                    ]
        , where = "YEAR(transaction_date) >= '" ~ var("all_transactions_scope_date") 
            ~ "' AND transaction_type IN ('" ~ var("all_transactions_scope_type") | join("', '") ~ "')") }}
),

data_consolidation AS 
(
    SELECT 
        t.* 
        , DENSE_RANK () OVER ( ORDER BY {{ var("dbt_snapshot_col_name") }} DESC )                    AS snapshot_date_order
        , {{ dbt_utils.star(from=ref('dim_bu'), except = var("scd_excluded_col_name") ) }}
        , COALESCE( fx_dated.fx_rate_original_to_usd, fx_latest.fx_rate_original_to_usd )            AS fx_rate_original_to_usd
        , COALESCE( fx_dated.fx_rate_original_to_dynamic, fx_latest.fx_rate_original_to_dynamic )    AS fx_rate_original_to_dynamic
        , '{{ var("fx_avg_implicit_currency") }}'                                                    AS dynamic_target_currency

    FROM union_current_and_snapshot t
    {# Common dimensions for all tansaction types #}
    LEFT OUTER JOIN {{ ref("dim_bu") }} bu
        ON bu.pk_{{ var("business_unit_key") }} = t.fk_{{ var("business_unit_key") }}
        AND t.transaction_date BETWEEN bu.scd_valid_from_fill_date AND bu.scd_valid_to_fill_date
    {# Fx rates #}
    LEFT OUTER JOIN {{ ref("fact_fx_avg_rate_latest") }} fx_latest
        ON bu.hist_bu_currency = fx_latest.original_currency
    LEFT OUTER JOIN {{ ref("fact_fx_avg_rate_dated") }} fx_dated
        ON bu.hist_bu_currency = fx_dated.original_currency
        AND EOMONTH(t.transaction_date) = fx_dated.closing_date
)

SELECT 
    * 
    , fx_rate_original_to_usd     * bu_amount AS usd_amount
    , fx_rate_original_to_dynamic * bu_amount AS dynamic_amount
FROM data_consolidation