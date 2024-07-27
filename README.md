# AppSec Scanning Terraform modules

Manage scheduled security scans of your APIs and web apps with Terraform.

These modules allow you to:

1. Execute scans against APIs and Web Apps within your VPC as a cron job with AWS Eventbridge
2. Automatically generate API scanning targets by generating a Swagger doc from code analysis
3. Create and manage inventories of NightVision targets (both Web apps and APIs)

# Prerequisites

* Sign up for NightVision: https://app.nightvision.net/
* [Install the NightVision CLI](#installing-the-nightvision-cli)
* [Generate a NightVision token](#generate-a-nightvision-token) and store it in a `nightvision.auto.tfvars` file.

# Tutorial

## Create a scheduled scan to run inside your VPC

* Create a file called `variables.tf`:

```hcl
variable "nightvision_token" {
  description = "The NightVision token to use for authentication"
  sensitive   = true
}

locals {
  project           = "terraform-example"
  security_group_id = "sg-0839aeaccdda71f96"
  subnet_id         = "subnet-07a080852c0769a32"
}
```

* Now generate a NightVision token and store it in `nightvision.auto.tfvars` (ignored by git) so you can work with the NightVision API:

```bash
export NIGHTVISION_TOKEN=$(nightvision token create)
echo 'nightvision_token = "'$NIGHTVISION_TOKEN'"' > nightvision.auto.tfvars
```

* Specify your targets in `targets.tf`:

```hcl
locals {
  web_targets = [
    {
      target_name = "testphp"
      project     = local.project
      url         = "http://testphp.vulnweb.com/"
    },
    {
      target_name = "javaspringvulny-web"
      project     = local.project
      url         = "https://javaspringvulny.nvtest.io:9000/"
    },
    // Add more targets as needed
  ]

  public_api_targets = [
    {
      target_name        = "javaspringvulny-api"
      project            = local.project
      url                = "https://javaspringvulny.nvtest.io:9000/"
      openapi_public_url = "https://raw.githubusercontent.com/vulnerable-apps/javaspringvulny/main/openapi.yaml"
    }
  ]
}
```

* Define your weekly scans in `weekly_scans.tf`:

```hcl
locals {
  # Define weekly scans
  scan_configs = [
    {
      schedule_name     = "scan-testphp"
      target            = "testphp"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
    {
      schedule_name     = "scan-javaspringvulny-web"
      target            = "javaspringvulny-web"
      auth              = "javaspringvulny-web"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
    // Add more schedules as needed
  ]
}
```

* And finally, call the module to create the scheduled scans in `main.tf`:

```hcl
# This will schedule scans for every 7 days
module "private_dast_scans" {
  source            = "github.com/nvsecurity/terraform-appsec-scanning"
  nightvision_token   = var.nightvision_token
  scan_configs        = local.scan_configs
  create_project_name = local.project
  web_targets         = local.web_targets
  public_api_targets  = local.public_api_targets
}
```

# Additional usage

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
