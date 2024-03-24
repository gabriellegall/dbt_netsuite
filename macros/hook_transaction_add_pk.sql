{% macro hook_transaction_add_pk() %}

    {% if not is_incremental() %}

        ALTER TABLE {{ this }}
        ADD CONSTRAINT {{ var("pk_transaction_with_line") }} PRIMARY KEY NONCLUSTERED ([transaction_nsid], [transaction_line_nsid]);

    {% endif %}

{% endmacro %}