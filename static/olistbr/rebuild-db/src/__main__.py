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
from pathlib import Path

import yaml
import pyodbc
import pandas as pd
from icecream import ic
# from pyodbc import Row, Connection, Cursor

from src.utils.paths import RAW_PATH, CONFIGS_PATH
from src.utils.db_manager import DBManager
from src.utils.db_config_manager import DBConfigManager

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


def main() -> None:
    # connect to default db
    dbm = DBManager(driver=driver, server=server, database=default_db)
    dbcm = DBConfigManager(db_config=db_config)

    # ic(dbcm.get_db(db))
    # ic(dbcm.list_schema_names(db))
    # ic(dbcm.get_schema("sales", db))
    # ic(dbcm.get_table("marketing.fact_marketing_qualified_leads"))
    # ic(dbcm.get_column("marketing.fact_marketing_qualified_leads.landing_page_id"))
    # ic(dbcm.get_column('logistics.dim_geolocation.geolocation_sk'))

    return

    with dbm.connect():
        # wipe db
        # dbm.wipe_db(db)
        # print(f"Wiped {db}")

        print(dbm.get_current_db())
        dbm.change_db(db)
        print(dbm.get_current_db())
        print(dbm.list_dbs())

        print(isinstance(db_config, dict))


if __name__ == "__main__":
    main()
