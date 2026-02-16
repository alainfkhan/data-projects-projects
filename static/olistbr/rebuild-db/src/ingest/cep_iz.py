"""
this file takes a dataset and splits it in two

dataset from: https://data.mendeley.com/datasets/g97jb8fp57/1
contributor: Ivan Zimmermann (iz)
published: 19 November 2019

saved in:
    data/external/raw/TB_CEP_BR_2018.csv

cleaned data will go:
    data/external/processed/TB_CEP_BR_2018__AuBmA.csv
    data/external/processed/TB_CEP_BR_2018__B.csv

later:
the tables in sqlserver will be called:
    logistics.dim_cep_iz_AuBmA
    logistics.dim_cep_iz_B

A = A u (B - A) - (B - A)
"""


def get_data() -> None:
    pass


def main() -> None:
    print("handle A")
    # if AuBmA exists
    #   return
    # else
    #   generate AuBma

    print("handle B")
    # if B exists
    #   return
    # else
    #   generate B

    # create tables if not exists


if __name__ == "__main__":
    main()
