ifndef ENVIRONMENT
$(error ENVIRONMENT is not set)
endif

TF_PLAN_FILE ?= local.tfplan

# defaults for local development in codespace
TF_BACKEND_BUCKET   ?= cloud-nova-corp-terraform
TF_BACKEND_KEY      ?= bananas.rails/$(ENVIRONMENT)/terraform.tfstate
TF_BACKEND_REGION   ?= eu-west-1

BACKEND_OPTIONS = \
	-backend-config 'bucket=$(TF_BACKEND_BUCKET)' \
	-backend-config 'use_lockfile=true' \
	-backend-config 'key=$(TF_BACKEND_KEY)' \
	-backend-config 'region=$(TF_BACKEND_REGION)'

TF_VARS = TF_VAR_environment=$(ENVIRONMENT) TF_VAR_remote_state_s3_bucket=$(TF_BACKEND_BUCKET) TF_VAR_remote_state_s3_region=$(TF_BACKEND_REGION) TF_VAR_image=$(TF_VAR_IMAGE)

.DEFAULT_GOAL := validate

.PHONY: clean
clean:
	rm -rf main.tf .terraform

main.tf: $(shell find . -mindepth 2 -name "*.tf")
	@cat $^ > $@

.PHONY: init
init: clean main.tf
	terraform init $(BACKEND_OPTIONS)

.PHONY: plan
plan: init
	$(TF_VARS) terraform plan

.PHONY: apply
apply: init
	$(TF_VARS) terraform apply

.PHONY: plan_write_file
plan_write_file: validate init
	$(TF_VARS) terraform plan -out=$(TF_PLAN_FILE)

.PHONY: apply_from_plan_file
apply_from_plan_file: init
	$(TF_VARS) terraform apply $(TF_PLAN_FILE)

.PHONY: upgrade
upgrade: clean main.tf
	terraform init -upgrade

.PHONY: validate
validate: init
	terraform validate
