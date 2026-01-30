.PHONY: paths
paths:
	python -m rebuild-db.src.utils.paths

.PHONY: format
format:
	#sqlfluff format queries
	ruff format .

# cannot run on conda env
# need to:
# 	deactivate conda current env
# 	source rebuild-db .venv
.PHONY: db
db:
	python -m rebuild-db.src

