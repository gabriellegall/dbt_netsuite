{{
    config (
        materialized = 'view'
    )
}}

WITH consolidate_data AS 

(
    SELECT 
        budget_year
        , budget_version
        {# customer_name cannot be matched with the dimension table and is therefore the only common field with the customer dimension #}
        , customer_name                                                                             AS live_customer_name
        , customer_name                                                                             AS hist_customer_name
        {# The bu_currency written in the Excel file is for user input clarity and traceability only, but can be replaced with the appropriate bu_currency from the dimension table #}
        , {{ dbt_utils.star(from=ref('dim_bu'), except = var("scd_excluded_col_name") ) }}
        , sales_amount_bu_currency
        , budget_date                                                                                AS calculation_date
        , COALESCE( fx_dated.fx_rate_original_to_usd, fx_latest.fx_rate_original_to_usd )            AS fx_rate_original_to_usd
        , COALESCE( fx_dated.fx_rate_original_to_dynamic, fx_latest.fx_rate_original_to_dynamic )    AS fx_rate_original_to_dynamic
        , '{{ var("fx_avg_implicit_currency") }}'                                                    AS dynamic_target_currency

    FROM {{ ref('sales_budget') }} bud
    LEFT OUTER JOIN {{ ref("fact_fx_avg_rate_latest") }} fx_latest
        ON bud.bu_currency = fx_latest.original_currency
    LEFT OUTER JOIN {{ ref("fact_fx_avg_rate_dated") }} fx_dated
        ON bud.bu_currency = fx_dated.original_currency
        AND EOMONTH(bud.budget_date) = fx_dated.closing_date
    LEFT OUTER JOIN {{ ref("prep_dim_bu_alternate_key_bu_code") }} bu
        ON bu.live_bu_code = bud.bu_code
)

SELECT
    *
    , fx_rate_original_to_usd       * sales_amount_bu_currency AS sales_amount_usd_currency
    , fx_rate_original_to_dynamic   * sales_amount_bu_currency AS sales_amount_dynamic_currency
FROM consolidate_data