# AppSec Scanning Terraform modules

Manage scheduled security scans of your APIs and web apps with Terraform.

These modules allow you to:

1. Execute scans against APIs and Web Apps within your VPC as a cron job with AWS Eventbridge
2. Automatically generate API scanning targets by generating a Swagger doc from code analysis
3. Create and manage inventories of NightVision targets (both Web apps and APIs)

# TODO

* Add an example for pointing to an OpenAPI spec that is publicly exposed, to make it easy to scan APIs that are not in your VPC

# Prerequisites

* Sign up for NightVision: https://app.nightvision.net/
* [Install the NightVision CLI](#installing-the-nightvision-cli)
* [Generate a NightVision token](#generate-a-nightvision-token) and store it in a `nightvision.auto.tfvars` file.

# Tutorial

## Create a scheduled scan to run inside your VPC

* First, create a NightVision project in `project.tf`:

```hcl
locals {
  project = "kinnaird"
}
module "nightvision_project" {
  source = "github.com/nvsecurity/terraform-appsec-scanning//modules/nv-project"
  project_name = local.project
}
```

* Next, create your targets with `targets.tf`:

```hcl
locals {
  targets = [
    {
      target_name = "testphp"
      target_type = "web"
      target_url  = "http://testphp.vulnweb.com/"
    },
    {
      target_name = "javaspringvulny-web"
      target_type = "web"
      target_url  = "https://javaspringvulny.nvtest.io:9000/"
    },
    {
      target_name = "javaspringvulny-api"
      target_type = "api"
      target_url  = "https://javaspringvulny.nvtest.io:9000/"
    }
    // Add more targets as needed
  ]
}
```

* Finally, create your scheduled scans in `schedules.tf`:

```hcl
locals {
  # replace with the ID of a security group that has access to the targets and open egress
  security_group_id = "sg-0839aeaccdda71f96"
  # replace with the ID of a subnet that has access to the targets
  subnet_id         = "subnet-07a080852c0769a32"
  project           = local.project
  scan_schedules = [
    {
      schedule_name     = "scan-testphp"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
      target            = "testphp"
    },
    {
      schedule_name     = "scan-javaspringvulny-web"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
      target            = "javaspringvulny-web"
      auth              = "javaspringvulny-web"
    },
    // Add more schedules as needed
  ]
}

module "private_dast_scans" {
  source            = "github.com/nvsecurity/terraform-appsec-scanning"
  nightvision_token = var.nightvision_token
  scan_schedules    = local.scan_schedules
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
