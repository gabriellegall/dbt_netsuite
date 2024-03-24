{% macro hook_transaction_drop_pk_constraint() %}

    {%- set target_relation = adapter.get_relation(
        database=this.database,
        schema=this.schema,
        identifier=this.name) -%}
    
    {%- set table_exists = target_relation is not none -%}
    
    {%- if table_exists -%}

        {% if not is_incremental() %}

            ALTER TABLE {{ this }}
            DROP CONSTRAINT IF EXISTS {{ var("pk_transaction_with_line") }};

        {% endif %}
    
    {%- endif -%}

{% endmacro %}