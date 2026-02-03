from pathlib import Path

import yaml
import pyodbc
import pandas as pd
from icecream import ic
from pyodbc import Row, Connection, Cursor

from src.utils.paths import RAW_PATH, CONFIGS_PATH
from src.utils.db_manager import DBManager

# get configs
tables_config_path: Path = CONFIGS_PATH / "tables.yml"
with open(tables_config_path, "r") as f:
    tables_config = yaml.safe_load(f)

connection_config_path: Path = CONFIGS_PATH / "connection.yml"
with open(connection_config_path, "r") as f:
    connection_config = yaml.safe_load(f)

# define variables from config
driver = connection_config["driver"]
server = connection_config["server"]
db_stg = connection_config["database"]
default_db = "master"
test_db = "deletesoon"

# connect to default db
dbm = DBManager(driver=driver, server=server, database=default_db)
conn: Connection = dbm.connect()
cursor: Cursor = conn.cursor()

print(dbm.get_current_db())


cursor.close()
conn.close()
