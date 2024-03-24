{% macro hook_drop_pk_constraint() %}

    {%- set target_relation = adapter.get_relation(
        database=this.database,
        schema=this.schema,
        identifier=this.name) -%}
    
    {%- set table_exists = target_relation is not none -%}
    
    {%- if table_exists -%}
        ALTER TABLE {{ this }}
        DROP CONSTRAINT IF EXISTS pk_transaction_with_line;
    {%- endif -%}

{% endmacro %}