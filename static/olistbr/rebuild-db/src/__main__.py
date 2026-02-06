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

import yaml
import pyodbc
import pandas as pd
from icecream import ic
# from pyodbc import Row, Connection, Cursor

from src.utils.paths import RAW_PATH, CONFIGS_PATH
from src.utils.db_manager import DBManager
from src.utils.db_config_manager import DBConfigManager

# ic.disable()

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

lines = 30 * "-"


def main() -> None:
    # connect to default db
    print(f"Connecting to server: '{server}'")
    dbm = DBManager(driver=driver, server=server, database=default_db)
    print("Connected")
    cm = DBConfigManager(db_config=db_config)

    # for table_name in dbcm.list_table_names():
    #     print(table_name)

    # with dbm.connect():
    #     print(dbm.get_current_db())
    #     print(dbm.change_db(db))
    #     print(dbm.list_tables())

    with dbm.connect():
        print(dbm.get_current_db())
        print(lines)
        # wipe db
        dbm.wipe_db(db)
        print(f"Wiped db: '{db}'")
        # print("List of dbs:")
        # print(f"\t{dbm.list_dbs()}")

        print(lines)

        # change to db
        print(dbm.change_db(db))
        print(lines)

        # create schemas
        for schema_name in cm.list_schema_names():
            print(dbm.create_schema(schema_name))

        print(lines)

        # create tables
        for table_name in cm.list_table_names():
            table = cm.get_table(table_name)
            print(dbm.create_table(table_name, table))

        # insert tables

        db_tables = dbm.list_tables()
        db_schemas = dbm.list_schemas()

        print(lines)

        print("Database:")
        print(f"{dbm.get_current_db()}")
        print(lines)

        print(f"[{len(db_schemas)}] Schemas:")
        print("\n".join(db_schemas))
        print(lines)

        print(f"[{len(db_tables)}] Tables:")
        print("\n".join(db_tables))
        print(lines)


if __name__ == "__main__":
    main()
