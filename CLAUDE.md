# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Monorepo for a Rails API application (`bananas/`) deployed to AWS ECS via CodeDeploy, with Terraform infrastructure (`terraform/`).

## Rails App (`bananas/`)

Ruby 3.3.10, Rails 8.1.2 (API-only, no views/assets), no database.

### Commands

Run all from within the `bananas/` directory:

```bash
bin/ci                  # full CI suite (lint + security + tests)
bin/rails test          # run all tests
bin/rails test test/controllers/api/bananas_controller_test.rb  # single test file
bin/rubocop             # lint
bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error  # security scan
bin/bundler-audit       # gem vulnerability check
bin/setup               # install deps and prepare environment
bin/rails server        # dev server (port 3000)
```

### Architecture

- API-only Rails app — controllers inherit from `ActionController::API`
- Routes: `GET /up` (health check), `GET /api/bananas` (returns `{ "yellow": true }`)
- All API controllers live under `app/controllers/api/` and are namespaced as `Api::`
- No models, no database, no ActiveRecord
- Production server: Thruster (HTTP/2 proxy) in front of Puma — `./bin/thrust ./bin/rails server`
- Docker: multi-stage build, runs as non-root `rails` user (UID 1000), exposes port 80

## GitHub Actions Workflows

### `ci.yml`
Runs on all branches (push + PR + manual). Executes tests, lint, and security scans only. Can also be called as a reusable workflow by `deploy.yml`.

### `deploy.yml`
Triggered on push to `main` or manually via `workflow_dispatch`. When triggered manually, prompts for `deployment_type` (`Blue/Green` or `Canary 10%, 5 minutes`). Full pipeline:
1. `ci` — calls `ci.yml` (tests/lint/security)
2. `push_image` — builds Docker image and pushes to ECR (tagged with commit SHA), via `ecr_push.yaml`
3. `apply_task_definition` — runs Terraform plan+apply to update the ECS task definition, via `terraform_plan_and_apply.yml`
4. `create_deployment` — creates a CodeDeploy deployment with the new task definition ARN, via `create-deployment.yml`

### Reusable workflows
- `ecr_push.yaml` — generic ECR build+push, reads AWS credentials from GitHub environment vars
- `terraform_plan_and_apply.yml` — runs Terraform plan then apply for production, passes `IMAGE` and `TF_VAR_IMAGE` to Makefile
- `create-deployment.yml` — calls `aws deploy create-deployment` with an inline AppSpec; maps `deployment_type` to `CodeDeployDefault.ECSAllAtOnce` or `CodeDeployDefault.ECSCanary10Percent5Minutes`
- `plan.yml` / `apply.yml` — low-level reusable Terraform plan and apply workflows
- `rails_ci.yml` — reusable Rails CI (scan, lint, test)

### GitHub Environments used
- `bananas-ecr-push` — vars: `AWS_IAM_ROLE_ARN_BANANAS_DEPLOY`, `AWS_IAM_REGION_BANANAS_DEPLOY`, `AWS_ECR_REPOSITORY_BANANAS`
- `production` — vars: `AWS_IAM_ROLE_TERRAFORM_APPLY`, `AWS_REGION_TERRAFORM_APPLY`, `TF_BACKEND_*`
- `production-code-deploy` — vars: `AWS_IAM_ROLE_ARN`, `AWS_REGION`, `CODEDEPLOY_APP_NAME`, `CODEDEPLOY_DEPLOYMENT_GROUP_NAME`

## Terraform (`terraform/`)

Manages the ECS task definition for the bananas app in `eu-west-1`. The `IMAGE` env var sets `var.image` (the ECR image URL) which is used in the container definition.

```bash
ENVIRONMENT=production make -f terraform/Makefile init      # initialize
ENVIRONMENT=production make -f terraform/Makefile plan      # plan changes
ENVIRONMENT=production make -f terraform/Makefile apply     # apply changes
ENVIRONMENT=production make -f terraform/Makefile validate  # validate config
```

- Backend: S3 bucket `cloud-nova-corp-terraform`, state key `bananas.rails/{environment}/terraform.tfstate`
- IAM: assumes role `arn:aws:iam::205899621967:role/fullaccess`
- Resources: ECS task definition (`bananas-bananas-web-production`)
- Output: `ecs_task_defintion_bananas` — ARN of the deployed task definition (note: typo in output name is intentional, matches Terraform state)
