USE olist_stg

-- rename main cep
IF (OBJECT_ID('logistics.dim_cep_iz_AuBmA')) IS NOT NULL
    BEGIN
        EXEC sp_rename 'logistics.dim_cep_iz_AuBmA', 'dim_cep'
    END;
