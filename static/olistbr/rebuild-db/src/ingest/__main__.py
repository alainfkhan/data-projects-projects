"""
this file deals with the main ingestion logic
orchestrator of additional data ingestions
"""

from pathlib import Path

import yaml
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


def main() -> None:
    # add generated sql tables
    dbm = DBManager(driver=driver, server=server, database=db)
    try:
        conn, cursor = dbm.connect()
    except Exception as e:
        print("ingest/__main__.py exeption message")
        print(e)
        return

    with conn:
        dbm.change_db(db)

        # create schemas:
        if "core" not in dbm.list_schemas():
            dbm.create_schema("core")
            print("Created schema: 'core'")

        gen_sql_path = REBUILD_DB_QUERIES_PATH / "rebuild-db"

        # regenerate core.dim_date
        sql_dim_date_path = gen_sql_path / "create-dim_date.sql"
        with open(sql_dim_date_path, "r") as f:
            sql_dim_date = f.read()

        conn.autocommit = True
        cursor.execute(sql_dim_date)
        # wait
        while cursor.nextset():
            pass
        conn.autocommit = False

        print("Regenerated:")
        print("\t'core.dim_date'")

        # generate core.dim_time

        # cep
        # generate cep files and get filepaths
        AuBmA_filepath, B_filepath = cep_iz_main()

        if AuBmA_filepath is None or B_filepath is None:
            print("CEP tables not inserted.")
        else:
            # generate cep tables
            geolocation_schema = "logistics"
            cep1_short = "dim_cep_iz_AuBmA"
            cep1_name = f"{geolocation_schema}.{cep1_short}"

            cep2_short = "dim_cep_iz_B"
            cep2_name = f"{geolocation_schema}.{cep2_short}"

            # create cep tables
            with open(gen_sql_path / "create-dim_cep_iz.sql", "r") as f:
                sql_cep_iz = f.read()

            cursor.execute(sql_cep_iz)
            conn.commit()
            print("Refreshed tables:")
            print(f"\t'{cep1_name}'")
            print(f"\t'{cep2_name}'")

            cep1_row_count, _ = dbm.get_table_shape(cep1_name)
            cep2_row_count, _ = dbm.get_table_shape(cep2_name)

            # insert file 1
            if cep1_row_count == 0:
                print(f"Inserting '{cep1_name}'...", end="\r")
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
                print(f"Table '{cep1_name}' inserted successfully.")
            else:
                print(f"Table '{cep1_name}' already exists.")

            # insert file2
            if cep2_row_count == 0:
                print(f"Inserting '{cep2_name}'...", end="\r")
                dbm.insert_from_csv(
                    filepath=B_filepath,
                    table_name=f"{cep2_name}",
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
                print(f"Table '{cep2_name}' inserted successfully.")
            else:
                print(f"Table '{cep2_name}' already exists.")


if __name__ == "__main__":
    main()
