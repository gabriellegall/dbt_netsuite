{% macro hook_add_pk_constraint_pt2() %}

    ALTER TABLE {{ this }}
    ADD CONSTRAINT pk_transaction_with_line PRIMARY KEY NONCLUSTERED ([transaction_nsid], [transaction_line_nsid]);

{% endmacro %}