.PHONY: run
run:
	python -m src

.PHONY: format
format:
	ruff format .

.PHONY: clean
clean:
	find . -type d -name '__pycache__' -exec rm -r {} +
	find . -type d -name '*.py[cod]' -exec rm -f {} +
	@echo "Python cache cleaned."