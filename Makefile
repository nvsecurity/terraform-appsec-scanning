SHELL:=/bin/bash

# ---------------------------------------------------------------------------------------------------------------------
# Environment setup and management
# ---------------------------------------------------------------------------------------------------------------------
virtualenv:
	python3 -m venv ./.venv && source .venv/bin/activate
setup-env: virtualenv
	python3 -m pip install -r requirements.txt