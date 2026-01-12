SHELL := /bin/bash

.PHONY: test
test:
	conda list --export > test.txt

REQ_TXT=requirements.txt
PIPL_TXT=piplist.txt
ENV_YML=environment.yml
ENV_NAME=dpp

# Conda is the package manager for this projects

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
# 	conda list --export > $(REQ_TXT)
	conda env export --from-history > $(ENV_YML)
	pip list --not-required --format=freeze > $(PIPL_TXT)
# 	need to append piplist to environment.yml

.PHONY: install
install:
	conda install --file $(REQ_TXT)

.PHONY: sync
sync:
# 	conda env update -f $(ENV_YML) --prune
	conda-lock install -n dpp

# ==================================================
# Linting
# ==================================================
.PHONY: format
format:
	ruff format .

.PHONY: lint
lint:
	ruff check .

#
# conda-lock -f environment.yml -p win-64 -p osx-arm64
#