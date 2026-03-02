.PHONY: format
format:
	sqlfluff format queries
	sqlfluff format rebuild-db/queries/rebuild-db
	ruff format .

# cannot run on conda env
# need to:
# 	deactivate conda current env
# 	source rebuild-db .venv

.PHONY: db
db:
	echo 'building-db'

# to rebuild db:
# cd rebuild-db
# source .venv/Scripts/activate
# python -m src

