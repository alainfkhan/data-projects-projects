.PHONY: run
run:
	python -m src

.PHONY: test
test:
	python -m src.utils.db_config_manager

.PHONY: paths
paths:
	python -m src.utils.paths

.PHONY: format
format:
	ruff format .

.PHONY: clean
clean:
	find . -type d -name '__pycache__' -exec rm -r {} +
	find . -type d -name '*.py[cod]' -exec rm -f {} +
	@echo "Python cache cleaned."