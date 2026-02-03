""" """

from icecream import ic
from pathlib import Path
from typing import Any, Generic, TypeVar, Dict, NamedTuple, TypedDict

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
        """Need to make a map:

        (db, schema, table) ie.

        (0,0,0) = (olist_stg, sales, dim_customers)

        (0,0,1) = (olist_stg, sales, dim_sellers)

        (0,0,2) = (olist_stg, sales, dim_product_category_name_translation)

        (0,1,0) = (olist_stg, marketing, fact_marketing_qualified_leads)

        (0,2,0) = (olist_stg, logistics, dim_geolocation)

        """
        self.db_config = db_config

        # make index
        # TODO: redo with more appropriate data structure
        coord_to_info: dict[DBCoord, DBInfo] = dict()
        # cood_to_info: dict[tuple[int, int, int], tuple[str, str, str]] = dict()
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
            hierarchy_to_comp["dbs"][db_name] = (db_id,)

            for schema_id, schema in enumerate(self.db_config[db_name]):
                schema_name = list(schema.keys())[0]

                hierarchy_to_comp["schemas"][schema_name] = (
                    db_id,
                    schema_id,
                )

                tables = list(schema.values())[0]
                for table_id, table in enumerate(tables):
                    table_name = list(table.keys())[0]

                    hierarchy_to_comp["tables"][table_name] = (
                        db_id,
                        schema_id,
                        table_id,
                    )

                    columns = list(table.values())[0]
                    for column_id, column in enumerate(columns["columns"]):
                        column_name = list(column.keys())[0]

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

        ic(coord_to_info)
        ic(hierarchy_to_comp)
        self.coord_to_info = coord_to_info
        self.hierarchy_to_comp = hierarchy_to_comp

    # TODO: rename after revision
    def get_table_info_from_coord(self, coord: tuple[int]) -> tuple[str]:
        pass

    def get_coord_from_table_info(self, table_info: tuple[str]) -> tuple[int]:
        pass

    def get_index_from_hierarchy(self, index: tuple[int]) -> str:
        pass

    def get_id(
        self,
        *,
        db: str | None = None,
        schema: str | None = None,
        table: str | None = None,
    ) -> tuple[int | None, int | None, int | None]:
        # ic(self.coord_to_table_info)
        # TODO: deprecate
        return (0, 0, 0)

    def get_db(self, db: str) -> dict[Any, Any]:
        """Returns the database configuration."""
        return self.db_config[db]

    def list_db_names(self) -> list[str]:
        return dict_keys_to_list(self.db_config.keys())

    def list_schema_names(self, db: str) -> list[str]:
        """Lists all schema names."""
        schema_names: list[str] = [list(s.keys())[0] for s in self.db_config[db]]
        return schema_names

    # TODO: need to find schema index since yml is sequenced
    def get_schema(self, schema: str, db: str) -> dict[Any, Any]:
        """Returns the schema configuration."""

        # print(schema)
        # print(db)

        db_id, schema_id, _ = self.get_id(db=db, schema=schema)

        # for s in self.db_config[db]:
        #     # ic(s)
        #     ic(s.keys())

        return

    def get_table(self, table: str) -> dict[Any, Any]:
        """Returns the table configuration."""
        pass

    def list_table_names(self) -> dict[Any, Any]:
        """Lists all table names in the form: <schema>.<table>"""
        pass

    pass


def main() -> None:
    db_config_path: Path = CONFIGS_PATH / "db_config.yml"
    with open(db_config_path, "r") as f:
        db_config = yaml.safe_load(f)

    pass


if __name__ == "__main__":
    main()
