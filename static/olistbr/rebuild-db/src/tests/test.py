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

    conn, cursor = dbm.connect()


if __name__ == "__main__":
    main()
