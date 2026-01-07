SHELL := /bin/bash

.PHONY: test
test:
	conda list --export > test.txt

REQ_TXT=requirements.txt
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
	conda list --export > $(REQ_TXT)
	conda env export --from-history > $(ENV_YML)
	@echo "Saved dependencies to $(REQ_TXT) and $(ENV_YML)."

.PHONY: install
install:
	conda install --file $(REQ_TXT)


# ==================================================
# Linting
# ==================================================
.PHONY: format
format:
	ruff format .

.PHONY: lint
lint:
	ruff check .
