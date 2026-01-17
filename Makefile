SHELL := /bin/bash

.PHONY: test
test:
	conda list --export > test.txt

REQ_TXT=requirements.txt
PIPL_TXT=piplist.txt
ENV_YML=environment.yml
ENV_MAN_YML=environment-man.yml
ENV_NAME=dpp

# Conda is the package manager for this projects
# environment-man.yml deps manually inputted

# ==================================================
# Clean
# ==================================================
.PHONY: clean
clean:
	find . -type d -name '__pycache__' -exec rm -r {} +
	find . -type d -name '*.py[cod]' -exec rm -f {} +
	@echo "Python cache cleaned."


# ==================================================
# Environment
# ==================================================
.PHONY: setup
setup:
	conda env create -f $(ENV_YML)


# ==================================================
# Dependencies
# ==================================================
.PHONY: save
save:  
	conda-lock -f $(ENV_MAN_YML) -p win-64 -p osx-arm64
	pip list --not-required --format=freeze > $(PIPL_TXT)

.PHONY: sync
sync:
# 	conda env update -f $(ENV_YML) --prune
	conda-lock install -n $(ENV_NAME) conda-lock.yml


# ==================================================
# Linting
# ==================================================
.PHONY: format
format:
	ruff format .

.PHONY: lint
lint:
	ruff check .