import os
from pathlib import Path

THIS_PATH = Path(__file__)
REBUILD_DB_PATH = THIS_PATH.parent.parent.parent
THIS_PROJECT_PATH = REBUILD_DB_PATH.parent

DATA_PATH = THIS_PROJECT_PATH / "data"
RAW_PATH = DATA_PATH / "raw"


def main() -> None:
    print("running paths.py")

    print(RAW_PATH)
    print(RAW_PATH.exists())


if __name__ == "__main__":
    main()
