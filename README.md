# AppSec Scanning Terraform modules

Manage scheduled security scans of your APIs and web apps with Terraform.

These modules allow you to:

1. Execute scans against APIs and Web Apps within your VPC as a cron job with AWS Eventbridge
2. Automatically generate API scanning targets by generating a Swagger doc from code analysis
3. Create and manage inventories of NightVision targets (both Web apps and APIs)

# Prerequisites

* Sign up for NightVision: https://app.nightvision.net/
* [Install the NightVision CLI](#installing-the-nightvision-cli)

# Usage

## Create a Web target

```hcl
# TODO: Add example
```

## Create an API target by uploading a Swagger file

```hcl
# TODO: Add example
```

## Create an API target by scanning the code with NightVision

```hcl
# TODO: Add example
```

## Create a scheduled scan to run inside your VPC

```hcl
# TODO: Add example
```

You will have to leverage a NightVision token to authenticate with the NightVision API. If you are testing this locally, you can create an .auto.tfvars file:

* [Generate a NightVision token](#generate-a-nightvision-token)

# Appendix: Additional Instructions

## Installing the NightVision CLI

**Mac OS installation**:

```bash
# Install:
brew install nvsecurity/taps/nightvision

# Upgrade to the latest version:
brew update && brew upgrade nightvision

# Install semgrep for authentication command
pip3 install semgrep --user
```

**Linux installation**:

```bash
# Intel:
curl -L https://downloads.nightvision.net/binaries/latest/nightvision_latest_linux_amd64.tar.gz -q | tar -xz; sudo mv nightvision /usr/local/bin/

# ARM:
curl -L https://downloads.nightvision.net/binaries/latest/nightvision_latest_linux_arm64.tar.gz -q | tar -xz; sudo mv nightvision /usr/local/bin/
```

* Log in to NightVision

```bash
nightvision login
```

This will open a browser window to authenticate with NightVision.

## Generate a NightVision token

* Once you have logged in, you can generate a NightVision token to be used with Terraform:

```bash
export NIGHTVISION_TOKEN=$(nightvision token create)
echo 'nightvision_token = "'$NIGHTVISION_TOKEN'"' > nightvision.auto.tfvars
```

That file is ignored by Git by default, so you won't accidentally commit it.

## Using the NightVision token in CI/CD

If you want to leverage that token in your Terraform code from a CI/CD pipeline, you can set the environment variable `TF_VAR_nightvision_token` to the token value. 

```bash
echo $NIGHTVISION_TOKEN
# Take the above value and store it as a secret in your CI/CD system
```

For example, you can follow these instructions to set up the secrets in GitHub Actions:
- [Creating secrets for a repository in the web UI](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions?tool=webui#creating-secrets-for-a-repository) 
- Creating secrets for a repository in the CLI](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions?tool=cli#creating-secrets-for-a-repository)

# Contributing

We can always use help improving these modules. If you have a suggestion, please open an issue or a pull request.

Note: This module makes heavy usage of Terraform's `null_resource` to create and manage NightVision targets. This is because NightVision does not have a Terraform provider yet.
