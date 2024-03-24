{% macro hook_transaction_add_not_null() %}

    {% if not is_incremental() %}

        ALTER TABLE {{ this }}
        ALTER COLUMN [transaction_nsid] INT NOT NULL;
        
        ALTER TABLE {{ this }}
        ALTER COLUMN [transaction_line_nsid] INT NOT NULL;

    {% endif %}

{% endmacro %}