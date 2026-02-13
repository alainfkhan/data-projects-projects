"""
db is the configuration
db_name is the name of the db

schema is the configuration
schema_name is the name of the schema

table is the configuration
table_short is the short name of the table
table_name is the name of the table = schema_name.table_short

column is the configuration
column_short is the short name of the column
column_name is the name of the column = schema_name.table_short.column_short

"""

from pathlib import Path
from typing import Any

import pandas as pd
import pyodbc
import yaml
from icecream import ic
from pyodbc import Row, Connection, Cursor
from pandas import DataFrame

from src.utils.db_config_manager import DBConfigManager
from src.utils.paths import CONFIGS_PATH

db_config_path: Path = CONFIGS_PATH / "db_config.yml"
with open(db_config_path, "r") as f:
    db_config = yaml.safe_load(f)

cm = DBConfigManager(db_config=db_config)

type_map: dict[str, type] = {
    "str": str,
    "int": int,
}


class DBManager:
    def __init__(self, driver: str, server: str, database: str) -> None:
        self.driver = driver
        self.server = server
        self.database = database

        self.default_db = "master"
        self.system_dbs = ["master", "model", "msdb", "tempdb"]

    def connect(self) -> tuple[Connection, Cursor]:
        """Connects to a database."""
        conn = pyodbc.connect(f"""
                            DRIVER={{{self.driver}}};
                            SERVER={self.server};
                            DATABASE={self.database};
                            Trusted_Connection=yes;
                            """)
        cursor = conn.cursor()

        self.conn = conn
        self.cursor = cursor
        return conn, cursor

    def is_sys_db(self, database: str) -> bool:
        """Checks if the input database is a core system database."""
        if database in self.system_dbs:
            return True
        return False

    def get_current_db(self) -> str | None:
        """Get name of the connected database."""
        self.cursor.execute("select db_name();")
        current_db = self.cursor.fetchone()
        if current_db:
            return current_db[0]
        return None

    def get_table_shape(self, table_name: str) -> tuple[int, int]:
        """Gets the number of rows and columns a table has."""
        split = table_name.split(".")
        schema_name = split[0]
        table_short = split[1]

        # rows
        get_rows = self.cursor.execute(f"select count(*) from {table_name}").fetchone()
        total_rows: int = 0 if get_rows is None else get_rows[0]

        # columns
        get_cols = self.cursor.execute(f"""
            select count(*)
            from information_schema.columns
            where table_schema = '{schema_name}'
                and table_name = '{table_short}'
        """).fetchone()
        total_cols: int = 0 if get_cols is None else get_cols[0]

        return total_rows, total_cols

    def change_db(self, database: str, execute: bool = True) -> str:
        """Change the database."""
        sql = f"USE {database};"
        if execute:
            self.cursor.execute(sql)
        return sql

    def list_dbs(self) -> list[str]:
        """List all databases in the server."""
        query = self.cursor.execute("""
            select name
            from master.sys.databases;
        """)
        rows: list[Row] = query.fetchall()

        all_dbs: list[str] = [row[0] for row in rows]
        return all_dbs

    def list_schemas(self) -> list[str]:
        """List created schemas in the connected-to database."""
        query = self.cursor.execute("""
            select name
            from sys.schemas
            where schema_id between 5 and 16383;
        """)
        rows: list[Row] = query.fetchall()

        schema_names: list[str] = [row[0] for row in rows]
        return schema_names

    def list_tables(self) -> list[str]:
        """List created tables in the connected-to database."""
        query = self.cursor.execute("""
            select
                table_schema,
                table_name
            from information_schema.tables;
        """)
        rows: list[Row] = query.fetchall()

        table_names: list[str] = [f"{row[0]}.{row[1]}" for row in rows]
        return table_names

    def list_schemas_in_db(self, db: str) -> list[str]:
        """Lists schemas in a database."""
        pass

    def list_table_shorts_in_schema(self, schema_name: str) -> list[str]:
        """List tables in a schema."""
        query = self.cursor.execute(f"""
            select table_name
            from information_schema.tables
            where table_schema = '{schema_name}'
        """)
        rows: list[Row] = query.fetchall()

        table_shorts: list[str] = [row[0] for row in rows]
        return table_shorts

    def list_columns_in_table(self, table_name: str) -> list[str]:
        """List columns in a table"""
        pass

    def query(self, sql: str) -> DataFrame:
        """Query the database, will only get rows, col names wont show."""
        # size set arb
        size = 10
        rows = self.cursor.execute(sql).fetchmany(size)
        df = pd.DataFrame(tuple(t) for t in rows)
        return df

    def disconnect_users_from_db(self, database: str, execute: bool = True) -> str:
        """
        After disconnecting users,
        must immediately commit to drop the db if intended.
        """

        sql = f"ALTER DATABASE {database} SET SINGLE_USER WITH ROLLBACK IMMEDIATE;"

        if execute:
            self.conn.autocommit = True
            self.cursor.execute(sql)
            self.conn.autocommit = False

        return sql

    def drop_db(self, database: str, execute: bool = True) -> str:
        """Drops a database if not connected to it."""
        if self.is_sys_db(database):
            raise ValueError("Cannot drop a system database.")

        if self.get_current_db() == database:
            raise ValueError("Cannot drop a database you're connected to.")

        sql = f"DROP DATABASE {database};"

        if execute:
            self.conn.autocommit = True
            self.cursor.execute(sql)
            self.conn.autocommit = False

        return sql

    def create_db(self, database: str, execute: bool = True) -> str:
        """Creates a new database."""
        # if database in self.list_dbs():
        #     raise ValueError(f"'{database}' already exists.")

        if self.is_sys_db(database):
            raise ValueError("Cannot create a system database.")

        sql = f"CREATE DATABASE {database};"

        if execute:
            self.conn.autocommit = True
            self.cursor.execute(sql)
            self.conn.autocommit = False

        return sql

    def create_schema(
        self,
        schema_name: str,
        execute: bool = True,
    ) -> str:
        """Creates a new schema."""
        sql = f"CREATE SCHEMA {schema_name};"

        if execute:
            self.conn.autocommit = True
            self.cursor.execute(sql)
            self.conn.autocommit = False

        return sql

    def create_table(
        self,
        table_name: str,
        table: dict[Any, Any],
        execute: bool = True,
    ) -> str:
        """Creates a new table.

        Returns the sql created.

        A schema for the table must exist.

        table is the table configuration
        """
        split = table_name.split(".")
        schema_name = split[0]
        table_short = split[1]

        # must be off for debug
        # if schema_name not in self.list_schemas():
        #     raise ValueError(f"Schema: '{schema_name}' does not exist.")

        sql: str = ""
        sql += f"CREATE TABLE {table_name} (\n"

        has_constraints: bool = "constraints" in list(table.values())[0]

        # TODO: get real type for column
        # columns
        columns = list(table.values())[0]["columns"]

        for i_col, column in enumerate(columns):
            column_short: str = list(column.keys())[0]

            dtype: str = column[column_short]["dtype"]

            nullable: bool = column[column_short]["nullable"]
            nullable_str: str = "" if nullable else " NOT NULL"

            has_sk: bool = "sk" in column[column_short]
            if has_sk:
                seed: int = column[column_short]["sk"]["seed"]
                increment: int = column[column_short]["sk"]["increment"]
                sk_str: str = f" IDENTITY({seed}, {increment})"
            else:
                sk_str = ""

            sql += f"\t{column_short} {dtype.upper()}{sk_str}{nullable_str}"

            is_last_col: bool = i_col == len(columns) - 1
            sql += ",\n" if has_constraints or not is_last_col else "\n"

        # constraints
        if has_constraints:
            constraints = list(table.values())[0]["constraints"]

            for i_constraint, constraint in enumerate(constraints):
                constraint_values = list(constraint.values())[0]
                constraint_name: str = list(constraint.keys())[0]
                constraint_type: str = constraint_values["type"]

                fk_ref_str = ""
                match constraint_type.upper():
                    case "PRIMARY KEY":
                        pk_cols = constraint_values["columns"]
                        col_str = ", ".join(pk_cols)
                    case "FOREIGN KEY":
                        fk_col = constraint_values["column"]
                        col_str = fk_col

                        fk_ref = constraint_values["references"]
                        fk_ref_schema: str = list(fk_ref.values())[0]["schema"]
                        fk_ref_table_short: str = list(fk_ref.keys())[0]
                        fk_ref_table_name = f"{fk_ref_schema}.{fk_ref_table_short}"

                        fk_ref_col = list(fk_ref.values())[0]["column"]

                        fk_ref_str = f"REFERENCES {fk_ref_table_name} ({fk_ref_col})"

                    case "UNIQUE":
                        uniue_cols: list[str] = constraint_values["columns"]
                        col_str: str = ", ".join(uniue_cols)
                    case "CHECK":
                        check_col = constraint_values["column"]
                        constraint_exp = constraint_values["expression"]
                        col_str = f"{check_col} {constraint_exp}"
                    case _:
                        col_str = "alsdf;alksdj;f"

                sql += "\n"
                sql += f"\tCONSTRAINT {constraint_name}\n"
                sql += f"\t\t{constraint_type} ({col_str})"

                if fk_ref_str:
                    sql += "\n"
                    sql += f"\t\t\t{fk_ref_str}\n"
                    sql += "\t\t\tON DELETE CASCADE\n"
                    sql += "\t\t\tON UPDATE CASCADE"

                is_last_constraint: bool = i_constraint == len(constraints) - 1
                if not is_last_constraint:
                    sql += ",\n"

            sql += "\n"
        sql += ");\n"

        # execute
        if execute:
            self.conn.autocommit = True
            self.cursor.execute(sql)
            self.conn.autocommit = False

        return sql

    def insert_from_csv(
        self,
        filepath: Path,
        table_name: str,
        column_shorts: list[str],
        execute: bool = True,
    ) -> str:
        """Insert data from a csv file into a created table.

        table_name is schema_name.table_short ie: sales.dim_customers

        column_shorts is a list of columns like: customer_id
        """
        # # old
        # df = pd.read_csv(filepath, keep_default_na=False, na_values=[""])
        # df = df.where(pd.notnull(df), None)
        # params = df.values.tolist()
        # do not print params

        split = table_name.split(".")
        schema_name = split[0]
        table_short = split[1]

        # get converters
        # TODO: remove dependency on dbconfigmanager in this file
        converters: dict[str, type] = dict()
        column_shorts = cm.list_column_shorts(table_name)
        for column_short in column_shorts:
            column_name = f"{schema_name}.{table_short}.{column_short}"
            column = cm.get_column(column_name)
            column_values = list(column.values())[0]

            has_converter = "converter" in column_values
            if has_converter:
                converter = column_values["converter"]
                converters[column_short] = type_map[converter]

        df = pd.read_csv(filepath, converters=converters)
        df_clean = df.astype(object).where(pd.notnull(df), None)
        df_clean = df_clean[column_shorts]

        params = list(df_clean.itertuples(index=False, name=None))

        sql: str = ""
        sql += f"INSERT INTO {table_name} (\n"
        sql += f"\t{',\n\t'.join(column_shorts)}\n"
        sql += ")\n"
        sql += f"VALUES ({', '.join(['?'] * len(column_shorts))});\n"

        if execute:
            self.cursor.fast_executemany = True
            try:
                self.cursor.executemany(sql, params)
                self.conn.commit()
            except Exception as e:
                print(f"Failed to insert '{table_name}': {e}")
                self.conn.rollback()
            self.cursor.fast_executemany = False

        return sql

    def wipe_db(
        self,
        database: str,
        execute: bool = True,
    ) -> str:
        """
        if in db change to master

        disconnect users from db

        drop db

        create db
        """
        # TODO: add argument: execute:bool=True
        # if execute=False dont execute, return sql
        # else exectue, return sql
        if self.is_sys_db(database):
            raise ValueError("Cannot wipe a system database.")

        complete_sql: str = ""

        current_db = self.get_current_db()
        if current_db == database:
            complete_sql += self.change_db(self.default_db, execute=execute)
            complete_sql += "\n\n"

        # if database exists
        if database in self.list_dbs():
            complete_sql += self.disconnect_users_from_db(database, execute=execute)
            complete_sql += "\n\n"
            complete_sql += self.drop_db(database, execute=execute)
            complete_sql += "\n\n"

        complete_sql += self.create_db(database, execute=execute)
        complete_sql += "\n\n"

        sql: str = ""
        sql += f"ALTER DATABASE {database}\n"
        sql += "SET RECOVERY SIMPLE;\n"

        complete_sql += sql

        # alter db logs
        if execute:
            self.conn.autocommit = True
            self.cursor.execute(sql)
            self.conn.autocommit = False

        return complete_sql


if __name__ == "__main__":
    pass
