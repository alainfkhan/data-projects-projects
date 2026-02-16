import os
from pathlib import Path

from icecream import ic

# this file path
THIS_PATH = Path(__file__)

# olistbr
THIS_PROJECT_PATH = THIS_PATH.parent.parent.parent.parent

DATA_PATH = THIS_PROJECT_PATH / "data"
RAW_PATH = DATA_PATH / "raw"
INTERIM_PATH = DATA_PATH / "interim"
PROCESSED_PATH = DATA_PATH / "processed"
EXTERNAL_PATH = DATA_PATH / "external"

# olistbr/rebuild-db/
REBUILD_DB_PATH = THIS_PROJECT_PATH / "rebuild-db"
CONFIGS_PATH = REBUILD_DB_PATH / "src" / "configs"

# olistbr/rebuild-db/queries
REBUILD_DB_QUERIES_PATH = REBUILD_DB_PATH / "queries"


def main() -> None:
    print("running paths.py")

    ic(REBUILD_DB_QUERIES_PATH)
    ic(REBUILD_DB_QUERIES_PATH.exists())


if __name__ == "__main__":
    main()
