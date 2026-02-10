"""
rebuilds the staging db

csv -> df -> sqlserver
"""

import os
import time
from pathlib import Path
from typing import NamedTuple

import yaml
import pyodbc
import pandas as pd
from pyodbc import Row
from rich.console import Console
from rich.table import Table
from icecream import ic
# from pyodbc import Row, Connection, Cursor

from src.utils.paths import RAW_PATH, CONFIGS_PATH
from src.utils.db_manager import DBManager
from src.utils.db_config_manager import DBConfigManager

# ic.disable()

# debugs
send_sql = False

wipe_db = True
create_schemas = True
create_tables = True
insert_tables = True

override_table_names = False
custom_table_names = [
    "sales.dim_customers",
    # "marketing.fact_closed_deals",
    # "logistics.dim_geolocation",
]

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
        # wipe db
        if send_sql and wipe_db:
            print(f"Wiping database: '{db}'...", end="\r")
            dbm.wipe_db(db)
            print(f"Successfully wiped database: '{db}'")
        else:
            print(f"DEBUG: <wipe database '{db}'>")

        print()
        print("SQL strings used:")
        print(long_lines)

        # change to db
        print(dbm.change_db(db))
        print(long_lines)

        # create schemas
        for schema_name in cm.list_schema_names():
            if send_sql and create_schemas:
                print(dbm.create_schema(schema_name))
            else:
                print(f"DEBUG: <create schema '{schema_name}' sql>")

        print(long_lines)

        # create tables and insert data
        if override_table_names:
            table_names = custom_table_names
        else:
            table_names = cm.list_table_names()

        for table_name in table_names:
            table = cm.get_table(table_name)
            table_values = list(table.values())[0]

            table_column_shorts = cm.list_column_shorts(table_name)

            filename = table_values["filename"]
            filepath: Path = RAW_PATH / filename
            if not filepath.exists():
                print(f"'{filepath}' does not exist.")

            # create table
            if send_sql and create_tables:
                print(dbm.create_table(table_name, table))
            else:
                print(f"DEBUG: <create table '{table_name}' sql>")

            # insert data
            if send_sql and insert_tables:
                print(f"Inserting: '{filepath.name}'...", end="\r")
                insert_sql: str = dbm.insert_from_csv(
                    filepath=filepath,
                    table_name=table_name,
                    column_shorts=table_column_shorts,
                )
                print(spaces)
                print(insert_sql)
            else:
                print(f"DEBUG: <insert table '{table_name}' sql>")

        print(long_lines)
        print()

        # database overview
        print(f"Overview of database: '{dbm.get_current_db()}'")
        print(short_lines)

        # schemas
        db_schemas = dbm.list_schemas()

        schema_table = Table(title="Schemas")
        schema_table.add_column("Schema name")
        schema_table.add_column("Tables")

        for schema in db_schemas:
            table_shorts = dbm.list_table_shorts_in_schema(schema_name=schema)
            schema_table.add_row(schema, str(len(table_shorts)))

        # tables
        db_tables = dbm.list_tables()

        tables_table = Table(title="Tables")
        tables_table.add_column("Table name")
        tables_table.add_column("Rows")
        tables_table.add_column("Columns")

        for table_name in db_tables:
            rows, cols = dbm.get_table_shape(table_name)
            tables_table.add_row(table_name, str(rows), str(cols))


        # columns
        query = cursor.execute("""
            SELECT
                TABLE_SCHEMA,
                TABLE_NAME,
                COLUMN_NAME,
                DATA_TYPE,
                CHARACTER_MAXIMUM_LENGTH,
                IS_NULLABLE
            FROM INFORMATION_SCHEMA.COLUMNS
        """)
        rows: list[Row] = query.fetchall()

        columns_table = Table(title="Colums")
        columns_table.add_column("Schema name")
        columns_table.add_column("Table name")
        columns_table.add_column("Column name")
        columns_table.add_column("Data Type")
        columns_table.add_column("Char. Max Length")
        columns_table.add_column("Is nullable")

        for row in rows:
            columns_table.add_row(
                str(row[0]),
                str(row[1]),
                str(row[2]),
                str(row[3]),
                str(row[4]),
                str(row[5]),
            )

        console = Console()
        console.print(schema_table)
        console.print(tables_table)
        # console.print(columns_table)

        print(short_lines)
        print(f"!!! '{db}' subject to repeated rewrites.")
        print("!!! Remember to copy the database.")
        print(short_lines)

if __name__ == "__main__":
    main()
