SHELL = /bin/sh

.PHONY: clean-raw
clean-raw:
	@echo 'Cleaning raw data'
	@python -m src.clean-raw

.PHONY: format
format:
	ruff format src
	ruff format notebooks