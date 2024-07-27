SHELL:=/bin/bash

# ---------------------------------------------------------------------------------------------------------------------
# Environment setup and management
# ---------------------------------------------------------------------------------------------------------------------
virtualenv:
	python3 -m venv ./.venv && source .venv/bin/activate
setup-env: virtualenv
	python3 -m pip install -r requirements.txt

# ---------------------------------------------------------------------------------------------------------------------
# Terraform stuff
# ---------------------------------------------------------------------------------------------------------------------
terraform-docs:
	terraform-docs markdown --output-file README.md --output-mode inject .
	# Replace mentions of "../../" with "github.com/nvsecurity/terraform-appsec-scanning" in README.md, like https://github.com/terraform-docs/terraform-docs/issues/606
	@sed -i '' 's|\.\./\.\./|github.com/nvsecurity/terraform-appsec-scanning|g' README.md

# ---------------------------------------------------------------------------------------------------------------------
# Terraform examples - testing
# ---------------------------------------------------------------------------------------------------------------------
apply-all-examples:
	# examples/project
	cd examples/project; terraform init && terraform validate && terraform plan && terraform apply -auto-approve; cd ../..
	# examples/infra-only
	cd examples/infra-only; terraform init && terraform validate && terraform plan && terraform apply -auto-approve; cd ../..
	# examples/schedule-only
	cd examples/schedule-only; terraform init && terraform validate && terraform plan && terraform apply -auto-approve; cd ../..
	# examples/simple-api-code-targets
	cd examples/simple-api-code-targets; terraform init && terraform validate && terraform plan && terraform apply -auto-approve; cd ../..
	# examples/simple-api-file-targets
	cd examples/simple-api-file-targets; terraform init && terraform validate && terraform plan && terraform apply -auto-approve; cd ../..
	# examples/simple-api-url-targets
	cd examples/simple-api-url-targets; terraform init && terraform validate && terraform plan && terraform apply -auto-approve; cd ../..
destroy-all-examples:
	# examples/simple-api-code-targets
	cd examples/simple-api-code-targets; terraform destroy -auto-approve; cd ../..
	# examples/simple-api-file-targets
	cd examples/simple-api-file-targets; terraform destroy -auto-approve; cd ../..
	# examples/simple-api-url-targets
	cd examples/simple-api-url-targets; terraform destroy -auto-approve; cd ../..
	# examples/schedule-only
	cd examples/schedule-only; terraform destroy -auto-approve; cd ../..
	# Destroy these last
	# examples/infra-only
	cd examples/infra-only; terraform destroy -auto-approve; cd ../..
	# examples/project
	cd examples/project; terraform destroy -auto-approve; cd ../..
apply-full:
	cd examples/full
	terraform init && terraform validate && terraform plan && terraform apply -auto-approve
apply-destroy-full:
	cd examples/full
	terraform init && terraform validate && terraform plan && terraform apply -auto-approve
	terraform destroy -auto-approve
