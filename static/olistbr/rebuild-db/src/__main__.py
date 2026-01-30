import os
from src.utils.paths import RAW_PATH

def main() -> None:
    print("rebuilding-db")

    print(RAW_PATH)
    print(RAW_PATH.exists())

    raw_paths = os.listdir(RAW_PATH)
    print(raw_paths)


if __name__ == "__main__":
    main()
