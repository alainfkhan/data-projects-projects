""" """

from icecream import ic
from pathlib import Path
from typing import Any, Generic, TypeVar, Dict, NamedTuple, TypedDict

import pandas as pd
import yaml
from pydantic import BaseModel, RootModel

from src.utils.paths import RAW_PATH, CONFIGS_PATH

T = TypeVar("T")

# class DBConfig(RootModel[Any]):
#     root: dict[str, list[Any]]

# class DBConfig(RootModel[Any]):
#     root: Dict
#     pass


class DBCoord(NamedTuple):
    db: int
    schema: int
    table: int
    column: int


class DBInfo(NamedTuple):
    db: str
    schema: str
    table: str
    column: str


# attempt
class TableComp(NamedTuple):
    db: tuple[int]
    schema: tuple[int, int]
    table: tuple[int, int, int]
    column: tuple[int, int, int, int]


def dict_keys_to_list(dict_keys) -> list[str]:
    return list(dict_keys)[0]


class DBConfigManager:
    """
    Manages the database configuration file.

    Assume the file contains exactly one db configuration.

    db > schema > table > column
    """

    def __init__(self, db_config: dict[Any, Any]) -> None:
        """ """
        self.db_config = db_config
        self.db_name = list(db_config.keys())[0]

        # make index
        coord_to_info: dict[DBCoord, DBInfo] = dict()
        # cood_to_info: dict[tuple[int, int, int], tuple[str, str, str]] = dict()
        hierarchy_to_id: dict[str, dict[str, int]] = {
            "dbs": {},
            "schemas": {},
            "tables": {},
            "columns": {},
        }
        hierarchy_to_comp: dict[
            str,
            dict[
                str,
                tuple[int]
                | tuple[int, int]
                | tuple[int, int, int]
                | tuple[int, int, int, int],
            ],
        ] = {
            "dbs": {},
            "schemas": {},
            "tables": {},
            "columns": {},
        }

        for db_id, db_name in enumerate(self.db_config):
            hierarchy_to_id["dbs"][db_name] = db_id
            hierarchy_to_comp["dbs"][db_name] = (db_id,)

            for schema_id, schema in enumerate(self.db_config[db_name]):
                schema_name = list(schema.keys())[0]

                hierarchy_to_id["schemas"][schema_name] = schema_id
                hierarchy_to_comp["schemas"][schema_name] = (
                    db_id,
                    schema_id,
                )

                tables = list(schema.values())[0]
                for table_id, table in enumerate(tables):
                    table_name = list(table.keys())[0]

                    hierarchy_to_id["tables"][table_name] = table_id
                    hierarchy_to_comp["tables"][table_name] = (
                        db_id,
                        schema_id,
                        table_id,
                    )

                    columns = list(table.values())[0]
                    for column_id, column in enumerate(columns["columns"]):
                        column_name = list(column.keys())[0]

                        hierarchy_to_id["columns"][column_name] = column_id
                        hierarchy_to_comp["columns"][column_name] = (
                            db_id,
                            schema_id,
                            table_id,
                            column_id,
                        )

                        coord: DBCoord = DBCoord(
                            db_id,
                            schema_id,
                            table_id,
                            column_id,
                        )
                        info: DBInfo = DBInfo(
                            db_name,
                            schema_name,
                            table_name,
                            column_name,
                        )
                        coord_to_info[coord] = info

        # ic(coord_to_info)
        # ic(hierarchy_to_id)
        # ic(hierarchy_to_comp)
        self.coord_to_info = coord_to_info
        self.hierarchy_to_id = hierarchy_to_id
        self.hierarchy_to_comp = hierarchy_to_comp

        df_db_info = pd.DataFrame(coord_to_info.values())
        self.df_db_info = df_db_info

    def _get_id(self, db_attr: str, value: str) -> int:
        db_attrs: list[str] = ["db", "schema", "table", "column"]
        singular_to_plural_map: dict[str, str] = {
            "db": "dbs",
            "schema": "schemas",
            "table": "tables",
            "column": "columns",
        }
        if db_attr not in db_attrs:
            raise ValueError(f"'{db_attr}' is not a valid database attribute.")
        plural = singular_to_plural_map[db_attr]

        id = self.hierarchy_to_id[plural][value]
        return id

    def list_db_names(self) -> list[str]:
        return dict_keys_to_list(self.db_config.keys())

    # def list_schema_names_2(self) -> list[str]:
    #     """Lists all schema names. Slower"""
    #     df = self.df_db_info
    #     df_schemas = df['schema'].drop_duplicates()
    #     schema_names = df_schemas.tolist()
    #     return schema_names

    def list_schema_names(self) -> list[str]:
        """List all schema names."""
        schema_names: list[str] = [
            list(s.keys())[0] for s in self.db_config[self.db_name]
        ]
        return schema_names

    def list_table_names(self) -> list[str]:
        """Lists all table names in the form: schema_name.table_name"""
        df = self.df_db_info
        df_tables = df[["schema", "table"]].drop_duplicates()
        table_names = [f"{row.schema}.{row.table}" for row in df_tables.itertuples()]
        return table_names

    def list_column_names(self) -> list[str]:
        df = self.df_db_info
        df_columns = df[["schema", "table", "column"]]
        column_names = [
            f"{row.schema}.{row.table}.{row.column}" for row in df_columns.itertuples()
        ]
        return column_names

    def get_db(self) -> dict[Any, Any]:
        """Returns the database configuration."""
        return self.db_config[self.db_name]

    def get_schema(self, schema_name: str) -> dict[Any, Any]:
        """Returns the schema configuration."""
        schema_id = self._get_id("schema", schema_name)
        schema = list(self.db_config.values())[0][schema_id]
        return schema

    def get_table(self, schema_table: str) -> dict[Any, Any]:
        """Returns the table configuration.

        schema_name has form: schema_name.table_name
        """
        schema_name = schema_table.split(".")[0]
        table_name = schema_table.split(".")[1]

        schema = self.get_schema(schema_name)

        table_id = self._get_id("table", table_name)
        tables = list(schema.values())[0]

        table = tables[table_id]
        return table

    def get_column(self, schema_table_column: str) -> dict[Any, Any]:
        """"""
        split = schema_table_column.split(".")
        schema_name = split[0]
        table_name = split[1]
        column_name = split[2]

        schema_table = f"{schema_name}.{table_name}"
        table = self.get_table(schema_table)

        column_id = self._get_id("column", column_name)

        columns = list(table.values())[0]["columns"]
        column = columns[column_id]

        return column


def main() -> None:
    db_config_path: Path = CONFIGS_PATH / "db_config.yml"
    with open(db_config_path, "r") as f:
        db_config = yaml.safe_load(f)

    pass


if __name__ == "__main__":
    main()
