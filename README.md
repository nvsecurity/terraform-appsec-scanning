# AppSec Scanning Terraform modules

Inject web app and API scans inside your AWS VPC with NightVision.

These modules allow you to:

1. Execute scans against APIs and Web Apps within your VPC as a cron job with AWS Eventbridge
2. Automatically generate API scanning targets by generating a Swagger doc from code analysis
3. Create and manage inventories of NightVision targets (both Web apps and APIs)

<!-- TOC start (generated with https://github.com/derlin/bitdowntoc) -->

- [Prerequisites](#prerequisites)
- [Tutorial](#tutorial)
   * [Create a scheduled scan to run inside your VPC](#create-a-scheduled-scan-to-run-inside-your-vpc)
   * [Inputs](#inputs)
- [Examples](#examples)
  + [Create a project](#create-a-project)
  + [Create scan automation infrastructure](#create-scan-automation-infrastructure)
  + [Create scheduled scans only](#create-scheduled-scans-only)
  + [Scan APIs by analyzing code](#scan-apis-by-analyzing-code)
  + [Scan APIs with an OpenAPI URL](#scan-apis-with-an-openapi-url)
  + [Scan APIs with a local OpenAPI file](#scan-apis-with-a-local-openapi-file)
  * [Resources](#resources)
- [Appendix: Additional Instructions](#appendix-additional-instructions)
   * [Installing the NightVision CLI](#installing-the-nightvision-cli)
   * [Generate a NightVision token](#generate-a-nightvision-token)
   * [Using the NightVision token in CI/CD](#using-the-nightvision-token-in-cicd)
- [Contributing](#contributing)

<!-- TOC end -->

# Prerequisites

* Sign up for NightVision: https://app.nightvision.net/
* [Install the NightVision CLI](#installing-the-nightvision-cli) and log in with: `nightvision login`

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

<!-- BEGIN_TF_DOCS -->

# Module Documentation

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_project_name"></a> [create\_project\_name](#input\_create\_project\_name) | Optionally, create a NightVision target. | `string` | `null` | no |
| <a name="input_create_scanner_infra"></a> [create\_scanner\_infra](#input\_create\_scanner\_infra) | Optionally, create the Lambda infrastructure. | `bool` | `true` | no |
| <a name="input_existing_scanner_lambda_name"></a> [existing\_scanner\_lambda\_name](#input\_existing\_scanner\_lambda\_name) | The name of the Lambda function that will be used to scan the target. | `string` | `"nightvision-scheduled-scan"` | no |
| <a name="input_existing_scheduler_role_name"></a> [existing\_scheduler\_role\_name](#input\_existing\_scheduler\_role\_name) | The name of the IAM role that will be used to schedule the scans. | `string` | `"NightVisionSchedulerExecutionRole"` | no |
| <a name="input_nightvision_token"></a> [nightvision\_token](#input\_nightvision\_token) | NightVision API token | `any` | n/a | yes |
| <a name="input_openapi_code_targets"></a> [openapi\_code\_targets](#input\_openapi\_code\_targets) | OpenAPI targets where the OpenAPI file is generated from analyzing local code paths. | <pre>list(object({<br>    url         = string<br>    project     = string<br>    language    = string<br>    target_name = string<br>    code_path   = string<br>  }))</pre> | `[]` | no |
| <a name="input_openapi_file_targets"></a> [openapi\_file\_targets](#input\_openapi\_file\_targets) | OpenAPI targets where the OpenAPI file is locally accessible. | <pre>list(object({<br>    url               = string<br>    project           = string<br>    target_name       = string<br>    openapi_file_path = string<br>  }))</pre> | `[]` | no |
| <a name="input_openapi_url_targets"></a> [openapi\_url\_targets](#input\_openapi\_url\_targets) | OpenAPI targets where the OpenAPI file is publicly accessible. | <pre>list(object({<br>    url                = string<br>    project            = string<br>    target_name        = string<br>    openapi_public_url = string<br>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy the Lambda function and scanner instances. | `string` | `"us-east-1"` | no |
| <a name="input_scan_configs"></a> [scan\_configs](#input\_scan\_configs) | List of scan configs | <pre>list(object({<br>    # AWS Arguments<br>    schedule_name       = string<br>    schedule_expression = optional(string, "rate(7 days)")<br>    # AWS Resources<br>    security_group_id = string<br>    subnet_id         = string<br>    # NightVision Constructs<br>    project = string<br>    target  = string<br>    auth    = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_web_targets"></a> [web\_targets](#input\_web\_targets) | Web Application Targets to scan. | <pre>list(object({<br>    url         = string<br>    project     = string<br>    target_name = string<br>  }))</pre> | `[]` | no |

## Resources


- data source.aws_caller_identity.current (main.tf#1)
- data source.aws_region.current (main.tf#2)

# Examples

## Create a project

This will just create a NightVision project.

```hcl
module "nightvision_project" {
  source               = "github.com/nvsecurity/terraform-appsec-scanning"
  create_project_name  = "terraform-example"
  nightvision_token    = var.nightvision_token
  create_scanner_infra = false
}
```

## Create scan automation infrastructure

This will create a Lambda function that will be able to launch ephemeral EC2 instances with scoped privileges and scan targets. 

```hcl
module "scan_infrastructure" {
  source               = "github.com/nvsecurity/terraform-appsec-scanning"
  nightvision_token    = var.nightvision_token
  create_scanner_infra = true
  region               = "us-east-1"
}
```

## Create scheduled scans only

If you don't want to create targets or infrastructure and you just want to schedule scans, this is a good example. 

```hcl
locals {
  project                     = "terraform-example"
  security_group_id           = "sg-0839aeaccdda71f96"
  subnet_id                   = "subnet-07a080852c0769a32"
}

module "weekly_scans" {
  source                      = "github.com/nvsecurity/terraform-appsec-scanning"
  nightvision_token           = var.nightvision_token
  scan_configs                = local.scan_configs
  create_scanner_infra        = false
}

locals {
  scan_configs = [
    {
      schedule_name     = "scan-testphp"
      target            = "testphp"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
  ]
}
```

## Scan APIs by analyzing code

NightVision can scan APIs that don't have existing OpenAPI specifications, by scanning code. If your code is locally accessible, you can generate the OpenAPI specs with NightVision:

```hcl
locals {
  project                     = "terraform-example"
  security_group_id           = "sg-0839aeaccdda71f96"
  subnet_id                   = "subnet-07a080852c0769a32"
}

module "weekly_scans" {
  source                      = "github.com/nvsecurity/terraform-appsec-scanning"
  nightvision_token           = var.nightvision_token
  scan_configs                = local.scan_configs
  openapi_code_targets        = local.openapi_code_targets
  create_scanner_infra        = false
}

locals {
  openapi_code_targets = [
    {
      target_name = "broken-flask-extracted"
      project     = local.project
      url         = "https://flask.brokenlol.com"
      language    = "python"
      code_path   = "${abspath(path.module)}/flask_app"
    },
  ]
  # Define weekly scans
  scan_configs = [
    {
      schedule_name     = "scan-broken-flask"
      target            = "broken-flask-extracted"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
  ]
}
```

## Scan APIs with an OpenAPI URL

NightVision can scan APIs that have publicly accessible OpenAPI specifications. You can provide the URL to the OpenAPI spec to NightVision:

```hcl
locals {
  project           = "terraform-example"
  security_group_id = "sg-0839aeaccdda71f96"
  subnet_id         = "subnet-07a080852c0769a32"
}

module "api_scans" {
  source                 = "github.com/nvsecurity/terraform-appsec-scanning"
  nightvision_token      = var.nightvision_token
  scan_configs           = local.scan_configs
  openapi_url_targets = local.openapi_url_targets
  create_scanner_infra   = false
}

locals {
  openapi_url_targets = [
    {
      target_name        = "jsv-api-from-url"
      project            = local.project
      url                = "https://javaspringvulny.nvtest.io:9000/"
      openapi_public_url = "https://raw.githubusercontent.com/vulnerable-apps/javaspringvulny/main/openapi.yaml"
    }
  ]
  # Define weekly scans
  scan_configs = [
    {
      schedule_name     = "scan-jsv-api-from-url"
      target            = "jsv-api-from-url"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
  ]
}
```

## Scan APIs with a local OpenAPI file

NightVision can scan APIs that have OpenAPI specifications stored locally. You can provide the path to the OpenAPI spec to NightVision:

```hcl
locals {
  project           = "terraform-example"
  security_group_id = "sg-0839aeaccdda71f96"
  subnet_id         = "subnet-07a080852c0769a32"
}

module "weekly_scans" {
  source               = "github.com/nvsecurity/terraform-appsec-scanning"
  nightvision_token    = var.nightvision_token
  scan_configs         = local.scan_configs
  openapi_file_targets = local.openapi_file_targets
  create_scanner_infra = false
}

locals {
  openapi_file_targets = [
    {
      url               = "https://flask.brokenlol.com"
      project           = local.project
      target_name       = "broken-flask-from-file"
      openapi_file_path = "${abspath(path.module)}/broken-flask-openapi.yml"
    },
  ]
  # Define weekly scans
  scan_configs = [
    {
      schedule_name     = "scan-broken-flask-from-file"
      target            = "broken-flask-from-file"
      project           = local.project
      security_group_id = local.security_group_id
      subnet_id         = local.subnet_id
    },
  ]
}
```
<!-- END_TF_DOCS -->

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

# TODO

- [ ] Terraform destroy won't work for the Lambda function if the zip file doesn't exist. So we should figure out how to handle that