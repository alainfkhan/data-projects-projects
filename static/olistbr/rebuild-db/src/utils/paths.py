import os
from pathlib import Path

# this file path
THIS_PATH = Path(__file__)

# olistbr
THIS_PROJECT_PATH = THIS_PATH.parent.parent.parent.parent

DATA_PATH = THIS_PROJECT_PATH / "data"
RAW_PATH = DATA_PATH / "raw"

# olistbr/rebuild-db/
REBUILD_DB_PATH = THIS_PROJECT_PATH / "rebuild-db"
CONFIGS_PATH = REBUILD_DB_PATH / "src" / "configs"


def main() -> None:
    print("running paths.py")

    print(CONFIGS_PATH)
    print(CONFIGS_PATH.exists())


if __name__ == "__main__":
    main()
