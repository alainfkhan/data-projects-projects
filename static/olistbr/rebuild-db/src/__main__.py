"""
rebuilds the staging db

will have:
olist
olist_stg

olist attained from copying olist_stg

csv -> pd -> sqlserver

assume exists
schema
table
column
dtype
nullable
pk
"""

import os
import time
from pathlib import Path
from typing import NamedTuple

import yaml
import pyodbc
import pandas as pd
from icecream import ic
# from pyodbc import Row, Connection, Cursor

from src.utils.paths import RAW_PATH, CONFIGS_PATH
from src.utils.db_manager import DBManager
from src.utils.db_config_manager import DBConfigManager

# ic.disable()

# debugs
send_sql = False

wipe_db = False
create_schemas = False
create_tables = False
insert_tables = False

override_table_names = True
custom_table_names = [
    "marketing.fact_closed_deals",
    "logistics.dim_geolocation",
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

long_lines = 80 * "-"
short_lines = 40 * "-"
equals = 80 * "="
spaces = 80 * " "


def main() -> None:
    # connect to default db
    print(f"Connecting to server: '{server}'", end="\r")
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
                print(f"DEBUG: <create schema '{schema_name}'>")

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
                print(f"Inserting: '{filepath.name}'", end="\r")
                insert_sql: str = dbm.insert_from_csv(
                    filepath,
                    table_name,
                    table_column_shorts,
                )
                print(spaces)
                print(insert_sql)
            else:
                print(f"DEBUG: <insert table '{table_name}' sql>")

        print(long_lines)
        print()

        db_tables = dbm.list_tables()
        db_schemas = dbm.list_schemas()

        print(f"Overview of database: '{dbm.get_current_db()}'")
        print(short_lines)

        # print("[#tables in schema] schema_name")
        print(f"{len(db_schemas)} total schemas in the database:")
        print(f"\t{'\n\t'.join(db_schemas)}")
        print(short_lines)

        # print("[#rows, #columns] table_name")
        print(f"{len(db_tables)} total tables in the database:")
        print(f"\t{'\n\t'.join(db_tables)}")
        # TODO: add [total_rows, total_cols]
        # print(f"[{total_rows}, {total_cols}]{'\n'.join(db_tables)}")
        print(short_lines)
        print(
            f"!!! '{db}' subject to repeated rewrites. Remember to copy the database."
        )


if __name__ == "__main__":
    main()
