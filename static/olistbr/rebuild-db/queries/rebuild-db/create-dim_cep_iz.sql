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
use olist_stg;

if (schema_id('logistics')) is null
    begin
        exec ('create schema logistics')
    end

-- first table
if (object_id('logistics.dim_cep_iz_AuBmA')) is not null
    begin
        set noexec on;
    end

create table logistics.dim_cep_iz_AuBmA (
    CEP char(8) not null,
    UF varchar(20) not null,
    CIDADE nvarchar(70) not null,
    BAIRRO nvarchar(70),
    LOGRADOURO nvarchar(150),
    COMPLEMENTO nvarchar(100),

    constraint pk_cep_iz_AuBmA
        primary key (CEP)
)

set noexec off;

-- second table
if (object_id('logistics.dim_cep_iz_B')) is not null
    begin
        set noexec on;
    end

create table logistics.dim_cep_iz_B (
    CEP char(8) not null,
    UF varchar(20) not null,
    CIDADE nvarchar(70) not null,
    BAIRRO nvarchar(70),
    LOGRADOURO nvarchar(150),

    constraint pk_cep_iz_B
        primary key (CEP)
)

set noexec off;