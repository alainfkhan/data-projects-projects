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
from pyodbc import Row, Connection, Cursor

from src.utils.paths import RAW_PATH, CONFIGS_PATH
from src.utils.db_manager import DBManager


def main() -> None:
    print("rebuilding-db")

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

    # connect to default db
    dbm = DBManager(driver=driver, server=server, database=default_db)
    conn: Connection = dbm.connect()
    cursor: Cursor = conn.cursor()
    # cursor defined here has to exist

    # wipe db
    dbm.wipe_db(db_stg)

    dbm.change_db(db_stg)

    schemas: list[str] = tables_config[db_stg].keys()
    for schema in schemas:
        dbm.create_schema(schema)

    # closing
    cursor.close()
    print("Cursor closed.")

    conn.close()
    print("Connection closed.")

    # dbm.drop_db('deletesoon')
    # print(dbm.list_all_dbs())

    # print(dbm.list_all_dbs())
    # print(dbm.create_db('deletesoon'))

    # print(dbm.list_tables())

    # print(dbm.query("SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'"))

    # dbmanager.rebuild_db()

    # dbmanager.query()

    # dbmanager.use()
    # dbmanager.current_db()
    # dbmanager.create_schema()
    # dbmanager.create_table()
    # dbmanager.insert_into_table()

    # default_db = "master"
    # print(f"Connecting to database: '{default_db}'...")
    # conn = pyodbc.connect(f"""
    #                       DRIVER={{{driver}}};
    #                       SERVER={server};
    #                       DATABASE={default_db};
    #                       Trusted_Connection=yes;
    #                       """)
    # cursor = conn.cursor()
    # cursor.fast_executemany = True
    # print(f"Connected to database: {default_db}.")

    # cursor.execute("select @@servername")
    # row: Row | None = cursor.fetchone()

    # print(row)
    # if row:
    #     print(row[0])

    # schema = "sales"
    # table = "dim_customers"

    # filename: str = tables_config[db][schema][table]["filename"]
    # filepath = RAW_PATH / filename

    # if not filepath.exists():
    #     raise FileNotFoundError(f"Filepath: '{filepath}' does not exist.")

    # df = pd.read_csv(filepath)
    # print(df)


if __name__ == "__main__":
    main()
