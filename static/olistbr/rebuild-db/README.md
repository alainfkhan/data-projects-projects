# rebuild-db

- Running `rebuild-db` drops and rebuilds a staging database, and inserts data from this project.
- The created staging database is intended to be copied and not used for analysis.
- `rebuild-db` uses `uv` as the python project manager.

## Setup environment

Go to the project directory:
```bash
cd rebuild-db
```

Deactivate any connected-to virtual environment:
```bash
deactivate
conda deactivate
```

Sync the environment using `uv`:
```bash
uv sync
```

## Rebuild the database

Run `src` to rebuild the database:
```bash
uv src
```

> [!NOTE]
> - You could be on debug mode.
> - To exit debug mode, go to `src.__main__.py`.
> - Find the variable `debug` just after imports and before `def main() -> None:`.
> - Change the bool of `debug` from `True` to `False`.
> - Run `src` to rebuild the database.
> - Then revert `debug` back to `True` to avoid any accidental rebuilds.
> - Don't use the created staging database for analysis.
> - Copy the staging database and use that for analysis.
