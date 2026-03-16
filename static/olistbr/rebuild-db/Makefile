.PHONY: run
run:
	uv run src | tee docs/stdout/cmd_execute.txt

.PHONY: ingest
ingest:
	uv run -m src.ingest

.PHONY: cep
cep:
	uv run -m src.ingest.cep_iz

.PHONY: test
test:
	python -m src.tests.test | tee test_output.txt


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