"""
rebuilds the staging db

csv -> df -> sqlserver
"""

import os
import time
import runpy
from pathlib import Path
from typing import NamedTuple

import yaml
import pyodbc
import pandas as pd
from pyodbc import Row
from rich import print
from rich.console import Console
from rich.table import Table
from icecream import ic
# from pyodbc import Row, Connection, Cursor

from src.utils.paths import RAW_PATH, CONFIGS_PATH, REBUILD_DB_PATH
from src.utils.db_manager import DBManager
from src.utils.db_config_manager import DBConfigManager

# ic.disable()

# debugs
execute = True

run_main = True
run_ingest = True

wipe_db = True
change_db = True
create_schemas = True
create_tables = True
insert_data = True

override_table_names = False
custom_table_names = [
    # "sales.dim_customers",
    # "marketing.fact_closed_deals",
    "logistics.fact_geolocation",
]

# maps
type_map: dict[str, type] = {
    "str": str,
    "int": int,
}

# get configs
connection_config_path: Path = CONFIGS_PATH / "connection.yml"
with open(connection_config_path, "r") as f:
    connection_config = yaml.safe_load(f)

db_config_path: Path = CONFIGS_PATH / "db_config.yml"
with open(db_config_path, "r") as f:
    db_config = yaml.safe_load(f)

# define variables from config
driver = connection_config["driver"]
server = connection_config["server"]
db = connection_config["database"]

default_db = "master"
test_db = "deletesoon"

long_lines = 100 * "-"
short_lines = 50 * "-"
equals = 80 * "="
spaces = 80 * " "


def mulitline_string_startwith(startwith: str, multiline_string: str) -> str:
    """For every new line in the multiline string, insert a startwith string."""
    out_str = "\n".join(f"{startwith}{line}" for line in multiline_string.splitlines())
    return out_str


def debug_str(multi_line_string: str) -> str:
    """Start with DEBUG: for every new line."""
    out = mulitline_string_startwith("DEBUG:    ", multiline_string=multi_line_string)
    return out


def sql_str(multi_line_string: str) -> str:
    out = mulitline_string_startwith(">>>       ", multiline_string=multi_line_string)
    return out


def main() -> None:
    # connect to default db
    print(f"Establishing a connection to server: '{server}'", end="\r")
    dbm = DBManager(driver=driver, server=server, database=default_db)
    conn, cursor = dbm.connect()

    print("Successful connection" + spaces)
    print(f"\tDriver used:            '{driver}'")
    print(f"\tConnected to server:    '{server}'")
    print(f"\tConnected to database:  '{dbm.get_current_db()}'")
    print()

    cm = DBConfigManager(db_config=db_config)

    with conn:
        print(f"SQL strings {'executed' if execute else 'generated but not executed'}:")

        print(long_lines)

        # wipe db
        if wipe_db:
            print(f"Wipe database '{db}':")
            print()
            print(f"Wiping database: '{db}'...", end="\r")

            sql_wipe_db: str = dbm.wipe_db(db, execute=execute)
            print(spaces, end="\r")
            print(sql_str(sql_wipe_db) if execute else debug_str(sql_wipe_db))

            print()
            print(long_lines)

        # change db
        if change_db:
            print("Switch to created database:")
            print()

            sql_change_db: str = dbm.change_db(db, execute=True)
            print(sql_str(sql_change_db) if execute else debug_str(sql_change_db))

            print()
            print(long_lines)

        # create schemas
        if create_schemas:
            print("Create schemas:")
            print()

            for schema_name in cm.list_schema_names():
                sql_create_schema: str = dbm.create_schema(schema_name, execute=execute)
                print(
                    sql_str(sql_create_schema)
                    if execute
                    else debug_str(sql_create_schema)
                )

            print()
            print(long_lines)

            print("Create tables and insert data:")
            print()

        # create tables and insert data
        if override_table_names:
            table_names = custom_table_names
        else:
            table_names = cm.list_table_names()

        for table_name in table_names:
            # separate names
            split = table_name.split(".")
            schema_name = split[0]
            table_short = split[1]

            # get table values
            table = cm.get_table(table_name)
            table_values = list(table.values())[0]

            table_column_shorts = cm.list_column_shorts(table_name)

            filename = table_values["filename"]
            filepath: Path = RAW_PATH / filename
            if not filepath.exists():
                print(f"'{filepath}' does not exist.")
                continue

            # create table
            if create_tables:
                sql_create_table: str = dbm.create_table(
                    table_name,
                    table,
                    execute=execute,
                )
                print(short_lines)
                print(f"'{filepath.name}'")
                print()
                print(
                    sql_str(sql_create_table)
                    if execute
                    else debug_str(sql_create_table)
                )

            # get converters
            converters: dict[str, type] = dict()
            for column_short in table_column_shorts:
                column_name = f"{schema_name}.{table_short}.{column_short}"
                column = cm.get_column(column_name)
                column_values = list(column.values())[0]

                has_converter = "converter" in column_values
                if has_converter:
                    converter = column_values["converter"]
                    converters[column_short] = type_map[converter]

            # insert data
            if insert_data:
                print()
                print(f"Inserting: '{filepath.name}'...", end="\r")
                sql_insert_from_csv: str = dbm.insert_from_csv(
                    filepath=filepath,
                    table_name=table_name,
                    column_shorts=table_column_shorts,
                    converters=converters,
                    execute=execute,
                )
                print(spaces, end="\r")
                # print(sql_str(insert_sql) if execute else debug_str(insert_sql))
                print(
                    f"{'Insert successful' if execute else 'Data not inserted'}"
                    if sql_insert_from_csv
                    else "Insert unsuccessful"
                )
                print()

        print(long_lines)

        # # database overview
        # print(f"Overview of database: '{dbm.get_current_db()}'")
        # print(short_lines)

        # # schemas
        # db_schemas = dbm.list_schemas()

        # schema_table = Table(title="Schemas")
        # schema_table.add_column("Schema name")
        # schema_table.add_column("Tables")

        # for schema in db_schemas:
        #     table_shorts = dbm.list_table_shorts_in_schema(schema_name=schema)
        #     schema_table.add_row(schema, str(len(table_shorts)))

        # # tables
        # db_tables = dbm.list_tables()

        # tables_table = Table(title="Tables")
        # tables_table.add_column("Table name")
        # tables_table.add_column("Rows")
        # tables_table.add_column("Columns")

        # for table_name in db_tables:
        #     rows, cols = dbm.get_table_shape(table_name)
        #     tables_table.add_row(table_name, str(rows), str(cols))

        # console = Console()
        # console.print(schema_table)
        # console.print(tables_table)

    return

    # # columns
    # query = cursor.execute("""
    #     SELECT
    #         TABLE_SCHEMA,
    #         TABLE_NAME,
    #         COLUMN_NAME,
    #         DATA_TYPE,
    #         CHARACTER_MAXIMUM_LENGTH,
    #         IS_NULLABLE
    #     FROM INFORMATION_SCHEMA.COLUMNS
    # """)
    # rows: list[Row] = query.fetchall()

    # columns_table = Table(title="Columns")
    # columns_table.add_column("Schema name")
    # columns_table.add_column("Table name")
    # columns_table.add_column("Column name")
    # columns_table.add_column("Data Type")
    # columns_table.add_column("Char. Max Length")
    # columns_table.add_column("Is nullable")

    # for row in rows:
    #     columns_table.add_row(
    #         str(row[0]),
    #         str(row[1]),
    #         str(row[2]),
    #         str(row[3]),
    #         str(row[4]),
    #         str(row[5]),
    #     )

    # # console.print(columns_table)


if __name__ == "__main__":
    # rebuild-db
    if run_main:
        main()
        print()

    # ingest supplementary data
    if run_ingest:
        print("Adding supplementary data")
        print(short_lines)

        ingest_filepath = REBUILD_DB_PATH / "src" / "ingest"
        runpy.run_path(str(ingest_filepath), run_name="__main__")

        print(long_lines)
        print()

    dbm = DBManager(
        driver=driver,
        server=server,
        database=db,
    )
    conn, cursor = dbm.connect()
    with conn:
        dbm.show_overview()

    print(short_lines)
    print(f"Successfully rebuilt '{db}'.")
    print(f"!!! '{db}' subject to repeated rewrites.")
    print("!!! Remember to copy the database.")
    print(short_lines)
