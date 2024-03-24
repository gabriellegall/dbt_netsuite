{% macro hook_add_pk_constraint_pt1() %}

    ALTER TABLE {{ this }}
    ALTER COLUMN [transaction_nsid] INT NOT NULL;
    
    ALTER TABLE {{ this }}
    ALTER COLUMN [transaction_line_nsid] INT NOT NULL;

{% endmacro %}