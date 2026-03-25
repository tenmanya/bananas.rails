# bananas.rails

A Rails API application deployed to AWS ECS via CodeDeploy, with Terraform-managed ECS task defintion.

The ECS infarstructure on which the app is managed in [bananas.terraform](https://github.com/cloud-nova-crop/bananas.terraform).


## What it does

Exposes a single API endpoint `GET /api/bananas` returning `{ "yellow": true }`.

## Stack

- **Ruby** 3.3.10 / **Rails** 8.1.2 (API-only)
- **AWS ECS** (Fargate) behind an Application Load Balancer
- **AWS CodeDeploy** for blue/green and canary deployments
- **Terraform** manages change to a single ECS task definition.

## Deployment

Deployments are triggered via the `deploy.yml` GitHub Actions workflow, manually with a choice of deployment strategy:

- **Blue/Green** — shifts 100% of traffic immediately (`CodeDeployDefault.ECSAllAtOnce`)
- **Canary 10%, 5 minutes** — shifts 10% of traffic first, then 100% after 5 minutes (`CodeDeployDefault.ECSCanary10Percent5Minutes`)

The pipeline builds a Docker image, pushes it to ECR, updates the ECS task definition via Terraform, then triggers a CodeDeploy deployment.
