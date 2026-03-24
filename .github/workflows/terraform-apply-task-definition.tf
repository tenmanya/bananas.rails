name: Terraform apply ECS task definition
run-name: terraformm-apply - ${{ inputs.module }}

on:
  workflow_dispatch:

permissions:
  contents: read
  id-token: write

jobs:
  plan-production:
    uses: ./.github/workflows/plan.yml
    with:
      environment: production
      github_environment: production
      terraform_plan_file_s3_prefix: s3://saito-berlin-terraform/_tfplan/example.terraform
      terraform_plan_id: ${{ github.run_id }}
      terraform_version_file: terraform/_config/versions.tf.json
    secrets: inherit
