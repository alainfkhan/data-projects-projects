use olist_stg

-- rename main cep
if (object_id('logistics.dim_cep_iz_AuBmA')) is not null
    begin
        exec sp_rename 'logistics.dim_cep_iz_AuBmA', 'dim_cep'
    end;
