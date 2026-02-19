/*
i have a table: TB_CEP_BR_2018.csv in data/external/
create tables only
do not do insertions

this file contains two tables A, B
table A has cols:
    CEP
    UF
    CIDADE
    BAIRRO
    LOGRADOURO
    COMPLEMENTO

table B has cols:
    CEP
    UF
    CIDADE
    BAIRRO
    LOGRADOURO

|B| > |A|
B does not contain A
AnB != B in A

create tables
    AuBmA = Au(B\A) = A union (B set minus A)
    B
*/
USE olist_stg;

IF (SCHEMA_ID('staging')) IS NULL
    BEGIN
        EXEC ('create schema staging')
    END

-- first table
IF (OBJECT_ID('staging.dim_cep_iz_AuBmA')) IS NOT NULL
    BEGIN
        SET NOEXEC ON;
    END

CREATE TABLE staging.dim_cep_iz_AuBmA (
    cep CHAR(8) NOT NULL,
    uf VARCHAR(20) NOT NULL,
    cidade NVARCHAR(70) NOT NULL,
    bairro NVARCHAR(70),
    logradouro NVARCHAR(150),
    complemento NVARCHAR(100),

    CONSTRAINT pk_cep_iz_AuBmA
        PRIMARY KEY (CEP)
)

SET NOEXEC OFF;

-- second table
IF (OBJECT_ID('staging.dim_cep_iz_B')) IS NOT NULL
    BEGIN
        SET NOEXEC ON;
    END

CREATE TABLE staging.dim_cep_iz_B (
    cep CHAR(8) NOT NULL,
    uf VARCHAR(20) NOT NULL,
    cidade NVARCHAR(70) NOT NULL,
    bairro NVARCHAR(70),
    logradouro NVARCHAR(150),

    CONSTRAINT pk_cep_iz_B
        PRIMARY KEY (CEP)
)

SET NOEXEC OFF;
