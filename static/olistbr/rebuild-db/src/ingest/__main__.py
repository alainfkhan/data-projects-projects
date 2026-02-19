"""
this file deals with the main ingestion logic
orchestrator of additional data ingestions
"""

from pathlib import Path

import yaml
from pyodbc import Connection, Cursor
from rich import print

from src.ingest.cep_iz import main as cep_iz_main
from src.utils.db_manager import DBManager
from src.utils.paths import REBUILD_DB_QUERIES_PATH, CONFIGS_PATH

# debugs
execute = True

# configs
with open(CONFIGS_PATH / "connection.yml", "r") as f:
    connection_config = yaml.safe_load(f)

# define variables from config
driver = connection_config["driver"]
server = connection_config["server"]
db = connection_config["database"]

add_schemas: list[str] = ["core"]
spaces = 80 * " "


def run_sql_file(conn: Connection, cursor: Cursor, filepath: Path) -> None:
    with open(filepath, "r") as f:
        sql = f.read()

    conn.autocommit = True
    cursor.execute(sql)

    # wait
    while cursor.nextset():
        pass

    conn.autocommit = False
    return


def print_run_sql_file(conn: Connection, cursor: Cursor, filepath: Path) -> None:
    print(f"Executing '{filepath.name}'...", end="\r")
    run_sql_file(
        conn=conn,
        cursor=cursor,
        filepath=filepath,
    )
    print(spaces, end="\r")
    print(f"Script '{filepath.name}' executed successfully.")


def main() -> None:
    # add generated sql tables
    dbm = DBManager(driver=driver, server=server, database=db)
    try:
        conn, cursor = dbm.connect()
    except Exception as e:
        print("ingest/__main__.py exeption message")
        print("Failed to establish connection.")
        print(e)
        return

    with conn:
        dbm.change_db(db)

        # run sql files
        gen_sql_path = REBUILD_DB_QUERIES_PATH / "rebuild-db"

        # dim_date
        dim_date_path = gen_sql_path / "create-dim_date.sql"
        print_run_sql_file(
            conn=conn,
            cursor=cursor,
            filepath=dim_date_path,
        )

        # dim_time
        dim_time_path = gen_sql_path / "create-dim_time.sql"
        print_run_sql_file(
            conn=conn,
            cursor=cursor,
            filepath=dim_time_path,
        )

        # cep
        # generate cep files and get filepaths
        AuBmA_filepath, B_filepath = cep_iz_main()

        if AuBmA_filepath is None or B_filepath is None:
            print("CEP tables not inserted.")
        else:
            # generate cep tables
            cep_schema = "staging"
            cep1_short = "dim_cep_iz_AuBmA"
            cep1_name = f"{cep_schema}.{cep1_short}"

            cep2_short = "dim_cep_iz_B"
            cep2_name = f"{cep_schema}.{cep2_short}"

            # create cep tables
            dim_cep_path = gen_sql_path / "create-dim_cep_iz.sql"
            print_run_sql_file(
                conn=conn,
                cursor=cursor,
                filepath=dim_cep_path,
            )

            cep1_row_count, _ = dbm.get_table_shape(cep1_name)
            cep2_row_count, _ = dbm.get_table_shape(cep2_name)

            # insert file 1
            if cep1_row_count == 0:
                print(f"Populating '{cep1_name}'...", end="\r")
                dbm.insert_from_csv(
                    filepath=AuBmA_filepath,
                    table_name=cep1_name,
                    column_shorts=[
                        "CEP",
                        "UF",
                        "CIDADE",
                        "BAIRRO",
                        "LOGRADOURO",
                        "COMPLEMENTO",
                    ],
                    converters={
                        "CEP": str,
                        "COMPLEMENTO": str,
                    },
                    execute=execute,
                )
                print(spaces, end="\r")
                print(
                    f"Table '{cep1_name}' populated with [{dbm.get_table_shape(cep1_name)[0]}] rows."
                )
            else:
                print(
                    f"Table '{cep1_name}' already populated with [{cep1_row_count}] rows."
                )

            # insert file2
            if cep2_row_count == 0:
                print(f"Populating '{cep2_name}'...", end="\r")
                dbm.insert_from_csv(
                    filepath=B_filepath,
                    table_name=cep2_name,
                    column_shorts=[
                        "CEP",
                        "UF",
                        "CIDADE",
                        "BAIRRO",
                        "LOGRADOURO",
                    ],
                    converters={"CEP": str},
                    execute=execute,
                )
                print(spaces, end="\r")
                print(
                    f"Table '{cep2_name}' populated with [{dbm.get_table_shape(cep2_name)[0]}] rows."
                )
            else:
                print(
                    f"Table '{cep2_name}' already populated with [{cep2_row_count}] rows."
                )

        last_things_path = gen_sql_path / "last_things.sql"
        print_run_sql_file(
            conn=conn,
            cursor=cursor,
            filepath=last_things_path,
        )


if __name__ == "__main__":
    main()
