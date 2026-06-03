SHELL = /bin/sh

.PHONY: example-data
example-data:
	head -11 data/raw/accepted_2007_to_2018Q4.csv/accepted_2007_to_2018Q4.csv > docs/data/accepted_2007_to_2018Q4.csv.example.csv
	head -11 data/raw/rejected_2007_to_2018Q4.csv/rejected_2007_to_2018Q4.csv > docs/data/rejected_2007_to_2018Q4.csv.example.csv

.PHONY: clean-raw
clean-raw:
	@echo 'Cleaning raw data'
	@python -m src.clean-raw

.PHONY: format
format:
	ruff format src
	ruff format notebooks