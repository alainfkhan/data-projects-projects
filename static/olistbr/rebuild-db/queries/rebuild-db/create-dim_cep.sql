/*
i have a table: TB_CEP_BR_2018.csv in data/external/

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

use olist_stg
