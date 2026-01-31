import os

import yaml
import pandas as pd
from icecream import ic
from typing import Dict

from src.utils.paths import RAW_PATH

"""
rebuilds the staging db

will have:
olist
olist_stg

csv -> pd -> sqlserver

assume exists
schema
table
column
dtype
nullable
pk
"""


def map_constraint(constraint: str) -> str:
    match constraint:
        case "pk":
            return "PRIMARY KEY"
        case "fk":
            return "FOREIGN KEY"
        case "unique":
            return "UNIQUE"
        case _:
            return ""


# type constraint_tree = Dict[str, constraint_tree | list[str]]
# type constraint_tree = Dict[str, str | list[constraint_tree]]

type constraint_tree = Dict[str, str | list[str] | list[Dict[str, str]]]


def handle_constraint(constraint: str, constraint_attributes: constraint_tree) -> str:
    # TODO: fix types
    constraint_name = constraint_attributes["name"]
    return_str: str = f"CONSTRAINT {constraint_name}\n"

    match constraint:
        case "pk":
            pk_columns = constraint_attributes["columns"]
            return_str += f"PRIMARY KEY ({', '.join(pk_columns)})"

        case "fk":
            fk_col: str = str(constraint_attributes["column"])

            references_attributes = constraint_attributes["references"]

            references = [list(r.keys())[0] for r in references_attributes]

            return_str += f"FOREIGN KEY ({fk_col})\n"
            return_str += "REFERENCES\n"

            references_list = []
            for i, reference in enumerate(references):
                schema = constraint_attributes["references"][i][reference]["schema"]
                ref_col = constraint_attributes["references"][i][reference]["column"]

                references_list.append(f"{schema}.{reference} ({ref_col})")

            return_str += ", ".join(references_list)

        case "unique":
            unique_cols: list[str] = list(constraint_attributes["columns"])
            return_str += f"UNIQUE ({', '.join(unique_cols)})"

        case _:
            pass

    return return_str


def main() -> None:
    print("rebuilding-db")
    print("")

    config_path: str = "src/config.yml"
    with open(config_path, "r") as f:
        config = yaml.safe_load(f)

    db_final_name = "olist"
    db_stg_name = f"{db_final_name}_stg"
    db = db_stg_name

    print(f"USE {db};")
    print("GO")
    print("")

    schemas: list[str] = list(config[db].keys())
    for schema in schemas:
        tables: list[str] = list(config[db][schema].keys())
        for table in tables:
            print(f"CREATE TABLE {schema}.{table} (")

            columns: list[str] = list(config[db][schema][table]["columns"].keys())
            for column in columns:
                dtype: str = config[db][schema][table]["columns"][column]["dtype"]
                nullable: str = config[db][schema][table]["columns"][column]["nullable"]

                print(f"\t{column} {dtype}{'' if nullable else ' NOT NULL'},")

            print("")

            constraints: list[str] = list(
                config[db][schema][table]["constraints"].keys()
            )
            # TODO: add commas for list, formatting
            for constraint in constraints:
                constraints_attributes = config[db][schema][table]["constraints"][
                    constraint
                ]
                constraint_str = handle_constraint(constraint, constraints_attributes)

                print(f"{constraint_str}")

            print(");")
            print("")

    # table_name = 'dim_customers'

    # filename = config[db_name][schema][table_name]['filename']
    # file_path = RAW_PATH / filename


if __name__ == "__main__":
    main()
