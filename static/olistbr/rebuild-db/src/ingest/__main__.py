"""
orchestrator of additional data ingestions
"""

import yaml

from src.ingest.cep_iz import main as cep_iz_main
from src.utils.db_manager import DBManager
from src.utils.paths import REBUILD_DB_QUERIES_PATH, CONFIGS_PATH

with open(CONFIGS_PATH / "connection.yml", "r") as f:
    connection_config = yaml.safe_load(f)

driver = connection_config["driver"]
server = connection_config["server"]
db = connection_config["database"]

add_schemas: list[str] = ["core"]


def main() -> None:
    # add generated sql tables
    dbm = DBManager(driver=driver, server=server, database=db)
    try:
        conn, cursor = dbm.connect()

        with conn:
            print(dbm.get_current_db())

            # create schemas:
            if "core" not in dbm.list_schemas():
                print(dbm.create_schema("core"))

            # get dim_date sql file
            gen_sql_path = REBUILD_DB_QUERIES_PATH / "rebuild-db"
            sql_dim_date_path = gen_sql_path / "create-dim_date.sql"
            with open(sql_dim_date_path, "r") as f:
                sql_dim_date = f.read()

            cursor.execute(sql_dim_date)
            conn.commit()

    except Exception as e:
        print("ingest/__main__.py exeption message")
        print(e)

    # handle cep files
    # TODO: split csv to 2, then create sql
    cep_iz_main()


if __name__ == "__main__":
    print("running src/ingest/__main__.py")
    main()
