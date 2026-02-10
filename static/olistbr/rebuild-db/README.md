# rebuild-db

## Notable analysis projects

- [Olist](https://github.com/alainfkhan/data-projects-projects/blob/main/static/olistbr/README.md)
    - [**rebuild-db**](https://github.com/alainfkhan/data-projects-projects/blob/main/static/olistbr/rebuild-db/README.md)
- [Restaurant Business Online](https://github.com/alainfkhan/data-projects-projects/blob/main/macos/bogacz-res/README.md)

---

- Running `rebuild-db` drops and rebuilds a staging database, and inserts data from this project.
- The created staging database is intended to be copied and should not be used for analysis.
- `rebuild-db` uses `uv` as the python project manager.

## Setup the virtual environment

Go to the project directory:
```bash
cd rebuild-db
```

Remember to deactivate any connected-to virtual environments:
```bash
deactivate
conda deactivate
```

Sync the environment using `uv`:
```bash
uv sync
```

## Rebuild the database by running `src`

Run `src` to rebuild the database:
```bash
make run
```
Or:
```bash
uv run src
```


> [!NOTE]
> - You could be on debug mode.
> - To exit debug mode, go to [`src/__main__.py`](https://github.com/alainfkhan/data-projects-projects/blob/main/static/olistbr/rebuild-db/src/__main__.py).
> - Find the variable `send_sql` just after imports and before `def main() -> None:`.
> - Change the bool of `send_sql` from `False` to `True`.
> - Change any of the other bools as required.
> - Run `src` to rebuild the database.
> - Then revert `send_sql` back to `False` to avoid any accidental rebuilds.
> - Do not use the created staging database for analysis.
> - Copy the staging database and use that for analysis.
