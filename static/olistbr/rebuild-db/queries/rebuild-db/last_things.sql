-- USE olist_stg

-- rename main cep
IF (OBJECT_ID('staging.dim_cep_iz_AuBmA')) IS NOT NULL
    BEGIN
        EXEC sp_rename 'staging.dim_cep_iz_AuBmA', 'dim_cep'
        alter schema logistics transfer staging.dim_cep
    END;
