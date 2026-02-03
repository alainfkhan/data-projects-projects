""" """

from icecream import ic
from pathlib import Path
from typing import Any, Generic, TypeVar, Dict

import yaml
from pydantic import BaseModel, RootModel

from src.utils.paths import RAW_PATH, CONFIGS_PATH

T = TypeVar("T")

# class DBConfig(RootModel[Any]):
#     root: dict[str, list[Any]]

# class DBConfig(RootModel[Any]):
#     root: Dict
#     pass


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

        (1,1,1) = (olist_stg, sales, dim_customers)

        (1,1,2) = (olist_stg, sales, dim_sellers)

        (1,1,3) = (olist_stg, sales, dim_product_category_name_translation)

        (1,2,1) = (olist_stg, marketing, fact_marketing_qualified_leads)

        (1,3,1) = (olist_stg, logistics, geolocation)

        """
        self.db_config = db_config

        # make index
        # TODO: redo with more appropriate data structure
        coord_to_table_info: dict[tuple[int, int, int], tuple[str, str, str]] = dict()
        hierarchy_to_index: dict[Any, Any] = {"db": {}, "schema": {}, "table": {}}

        for db_id, db_name in enumerate(self.db_config):
            hierarchy_to_index["db"][db_name] = db_id

            for schema_id, schema in enumerate(self.db_config[db_name]):
                schema_name = list(schema.keys())[0]
                tables = list(schema.values())[0]

                hierarchy_to_index["schema"][schema_name] = (db_id, schema_id)

                for table_id, table in enumerate(tables):
                    table_name = list(table.keys())[0]

                    idx = (db_id, schema_id, table_id)
                    loc = (db_name, schema_name, table_name)
                    coord_to_table_info[idx] = loc

                    hierarchy_to_index["table"][table_name] = (
                        db_id,
                        schema_id,
                        table_id,
                    )

        ic(coord_to_table_info)
        ic(hierarchy_to_index)
        self.coord_to_table_info = coord_to_table_info
        self.hierarchy_to_index = hierarchy_to_index

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
