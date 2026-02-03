import pandas as pd
import pyodbc
from pyodbc import Row, Connection
from pandas import DataFrame


class DBManager:
    def __init__(self, driver: str, server: str, database: str) -> None:
        self.driver = driver
        self.server = server
        self.database = database

        self.default_db = "master"
        self.system_dbs = ["master", "model", "msdb", "tempdb"]

    def connect(self) -> Connection:
        """Connects to a database."""
        conn = pyodbc.connect(f"""
                            DRIVER={{{self.driver}}};
                            SERVER={self.server};
                            DATABASE={self.database};
                            Trusted_Connection=yes;
                            """)
        self.conn = conn
        self.cursor = conn.cursor()
        return conn

    def get_current_db(self) -> str | None:
        """Get name of the connected database."""
        self.cursor.execute("select db_name();")
        current_db = self.cursor.fetchone()
        if current_db:
            return current_db[0]
        return None

    def change_db(self, database: str) -> None:
        """Change the database."""
        self.cursor.execute(f"use {database};")

    def list_dbs(self) -> list[str]:
        """List all databases in the server."""
        query = self.cursor.execute("""
            select name
            from master.sys.databases;
            """)
        rows: list[Row] = query.fetchall()

        all_dbs: list[str] = [row[0] for row in rows]
        # for row in rows:
        #     all_dbs.append(row[0])
        return all_dbs

    def list_schemas(self) -> list[str]:
        """List all schemas in the database."""
        query = self.cursor.execute("""
            select name
            from sys.schemas
            where schema_id between 5 and 16383
            """)
        rows: list[Row] = query.fetchall()

        schemas_in_db: list[str] = [row[0] for row in rows]
        return schemas_in_db

    def list_tables(self) -> list[str]:
        """List all tables database."""
        query = self.cursor.execute("""
            select
                table_schema,
                table_name
            from information_schema.tables
            where table_type='BASE TABLE';
            """)
        rows: list[Row] = query.fetchall()

        tables_in_db: list[str] = [f"{row[0]}.{row[1]}" for row in rows]
        # for row in rows:
        #     tables_in_db.append(f"{row[0]}.{row[1]}")
        return tables_in_db

    def query(self, sql: str) -> DataFrame:
        """Query the database, will only get rows, col names wont show."""
        # size set arb
        size = 10
        rows = self.cursor.execute(sql).fetchmany(size)
        df = pd.DataFrame(tuple(t) for t in rows)
        return df

    def is_sys_db(self, database: str) -> bool:
        """Checks if the input database is a core system database."""
        if database in self.system_dbs:
            return True
        return False

    def disconnect_users_from_db(self, database: str) -> None:
        """
        After disconnecting users,
        must immediately commit to drop the db if intended.
        """
        self.conn.autocommit = True
        self.cursor.execute(
            f"alter database {database} set single_user with rollback immediate;"
        )
        self.conn.autocommit = False
        pass

    def drop_db(self, database: str) -> None:
        """Drops a database if not connected to it."""
        if self.is_sys_db(database):
            raise ValueError("Cannot drop a system database.")

        if self.get_current_db() == database:
            raise ValueError("Cannot drop a database you're connected to.")

        self.conn.autocommit = True
        self.cursor.execute(f"drop database {database};")
        self.conn.autocommit = False

    def create_db(self, database: str) -> None:
        """Creates a new database."""
        if database in self.list_dbs():
            raise ValueError(f"'{database}' already exists.")

        if self.is_sys_db(database):
            raise ValueError("Cannot create a system database.")

        self.conn.autocommit = True
        self.cursor.execute(f"create database {database};")
        self.conn.autocommit = False
        return

    def create_schema(self, schema: str) -> None:
        self.conn.autocommit = True
        self.cursor.execute(f"create schema {schema};")
        self.conn.autocommit = False

    def create_table(self, table: str, col_spec) -> None:
        """Creates a table in a db.

        A schema for the table must exist.
        """
        pass

    def wipe_db(self, database: str) -> None:
        """
        if in db change to master

        disconnect users from db

        drop db

        create db
        """
        if self.is_sys_db(database):
            raise ValueError("Cannot wipe a system database.")

        current_db = self.get_current_db()
        if current_db == database:
            self.change_db(self.default_db)

        # if database exists
        if database in self.list_dbs():
            self.disconnect_users_from_db(database)
            self.drop_db(database)

        self.create_db(database)

        self.conn.autocommit = True
        self.cursor.execute(f"""
            alter database {database}
            set recovery simple
            """)
        self.conn.autocommit = False


if __name__ == "__main__":
    pass
