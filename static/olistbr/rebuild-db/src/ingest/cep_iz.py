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
    logistics.dim_cep_iz__AuBmA
    logistics.dim_cep_iz__B

A = A u (B - A) - (B - A)
"""

import pandas as pd
from icecream import ic

from src.utils.paths import EXTERNAL_PATH

# debugs
overwrite_if_exists = False


canon_filename = "TB_CEP_BR_2018.csv"
canon_filepath = EXTERNAL_PATH / "raw" / canon_filename

dataset_url = "https://data.mendeley.com/datasets/g97jb8fp57/1"


def get_data() -> None:
    pass


def main() -> None:
    """Creates two tables that are partitions of a table from the dataset url."""

    if not canon_filepath.exists():
        print(f"File '{canon_filename}' not found in '{canon_filepath.parent}'")
        print(f"Download the dataset from '{dataset_url}'")
        print(
            f"Save the downloaded dataset '{canon_filename}' to '{canon_filepath.parent}'"
        )
        return

    AuBmA_filename = f"{canon_filename.split('.')[0]}__AuBmA.csv"
    B_filename = f"{canon_filename.split('.')[0]}__B.csv"

    AuBmA_filepath = EXTERNAL_PATH / "processed" / AuBmA_filename
    B_filepath = EXTERNAL_PATH / "processed" / B_filename

    if AuBmA_filepath.exists() and B_filepath.exists() and not overwrite_if_exists:
        return

    df = pd.read_csv(
        canon_filepath,
        delimiter=";",
        dtype=str,
        encoding="utf_8",
    )

    # partition
    idx_repeat_header = df[df["CEP"].str.contains("CEP")].index[0]
    df_A = df.iloc[:idx_repeat_header, :].copy()
    df_B = df.iloc[idx_repeat_header + 1 :, :-1].copy().reset_index(drop=True)

    # A\B u B\a
    # symm_diff = set(df_A["CEP"]) ^ set(df_B["CEP"])

    # on col CEP, A\B
    # cep_AmB = set(df_A["CEP"]) - set(df_B["CEP"])

    # on col CEP B\A
    cep_BmA = set(df_B["CEP"]) - set(df_A["CEP"])

    # unique CEPs on table B
    cep_BmA_list = list(sorted(cep_BmA))
    df_BmA = df[df["CEP"].isin(cep_BmA_list)]

    # AuBmA means A u (B\A) means A union (B set minus A)
    df_AuBmA = pd.concat([df_A, df_BmA])

    if not AuBmA_filepath.exists() or overwrite_if_exists:
        print("creating AuBmA")
        df_AuBmA.to_csv(AuBmA_filepath, index=False)
        ic(AuBmA_filepath)

    if not B_filepath.exists() or overwrite_if_exists:
        print("creating B")
        df_B.to_csv(B_filepath, index=False)
        ic(B_filepath)


if __name__ == "__main__":
    main()
