# First attempt at a makefile to simplify some of the common commands. 
# 	Goal: maintain reasonable cross-platform capability between:
# 		- MacOS, 
# 		- WSL on Windows and 
# 		- native Linux 
.DEFAULT_GOAL := help

# General Variables
project := $(shell basename `pwd`)
workspace := "$(env)"
container := toybox-www
docker-filecheck := /.dockerenv
backend := ../backend.tfvars
docker-warning := ""
env-resources := ""

# Buiild up Terraform argument variables
terraform-backend-vars := -var-file=$(backend)
terraform-backend-config := -backend-config=$(backend)
ifeq ($(env), global)
	env-resources := ./resources/global
else
	env-resources := ./resources/env
endif
terraform-env-vars := -var-file=$(env).tfvars

# Docker Warning
ifeq ("$(wildcard $(docker-filecheck))","")
	docker-warning = "⚠️  WARNING: Can't find /.dockerenv - it's strongly recommended that you run this from within the docker container."
endif

# Targets
help:
	@echo "Docker-Helper functions for building & running the the $(project) container(s)"
	@echo "---------------------------------------------------------------------------------------------"
	@echo "Targets:"
	@echo "  Docker Targets (run from local machine)"
	@echo "   - up     : brings up the contaier(s) & attach to the default container ($(default-container))"
	@echo "   - down   : stops the container(s)"
	@echo "   - build  : (re)builds the container(s)"
	@echo "  Terraform Targets (should only be run inside the docker container)"
	@echo "   - init   : initialise terraform backend & modules"
	@echo "   - plan   : create terraform plan"
	@echo "   - apply  : apply terraform plan"
	@echo "  Service Targets (should only be run inside the docker container)"
	@echo "   - run    : run the service"
	@echo "   - deploy : deploy the service"
	@echo ""
	@echo "Options:"	
	@echo " - env    : sets the environment - supported environments are: global | dev | prod"	
	@echo ""
	@echo "Examples:"
	@echo " - Start Docker Container            : make up"
	@echo " - Rebuild Docker Container          : make build"
	@echo " - Rebuild & Start Docker Container  : make build up"
	@echo " - Plan Terraform Dev Env            : make env=dev plan"
	@echo " - Apply Terraform Dev Env           : make env=dev apply"

set-credentials:
	@echo "Validating the environment:"
	@# HACK: This is needed for WSL on Windows 10, since WSL has no way to map ~/.aws into a docker container, 
	@#       as the ~ folder in WSL seems to be inaccessible to Docker for Windows
	@# TODO: Find a better way. 
	@rsync -rup ~/.aws .

test: set-credentials
	@echo "Testin 1,2,3..."

up: set-credentials down
	@echo "Starting containers..."
	@docker-compose up -d
	@echo "Attachig shell..."
	@docker-compose exec $(container) bash

shell: set-credentials 
	@echo "Attachig shell..."
	@docker-compose exec $(container) bash

down: set-credentials
	@echo "Stopping containers..."
	@docker-compose down

build: set-credentials down
	@echo "Stopping containers..."
	@docker-compose down
	@echo "Building containers..."
	@docker-compose build

plan: 
	$(call check_defined, env, Please set the env to plan for. Supported environments are: global | dev | prod )
	
	@echo 'Switching to the [$(value workspace)] environment ...'
	@cd $(env-resources) ; \
		terraform fmt ; \
		terraform workspace select $(value workspace) ; \
		terraform plan $(terraform-backend-vars) $(terraform-env-vars) -out $(value env).tfplan

apply: 
	$(call check_defined, env, Please set the env to plan for. Supported environments are: global | dev | prod )
	
	@echo 'Switching to the [$(value workspace)] environment ...'
	@cd $(env-resources) ; \
		terraform fmt ; \
		terraform workspace select $(value workspace) ; \
		echo "Applying the following to [$(value env)] environment:" ; \
		terraform show -no-color $(value env).tfplan ; \
		terraform apply $(value env).tfplan

destroy: 
	$(call check_defined, env, Please set the env to plan for. Supported environments are: global | dev | prod )
	
	@echo 'Switching to the [$(value workspace)] environment ...'
	@cd $(env-resources) ; \
		terraform fmt ; \
		terraform workspace select $(value workspace) ; \
		terraform destroy $(terraform-backend-vars) $(terraform-env-vars)

init-state:
	#TODO: Test this a couple of times on new environments
	@echo "Here be dragons. We should subdue them soon"
	@echo ""
	@echo "Warning: You will need a local .tfstate for this to work, since this creates the backend tfstate for the other workspaces. If you don't have it, you will have to import it manually. One by one."
	@echo "	e.g.: cd ./resources/setup/terraform-backend; terraform import --var-file=../../backend.tfvars module.backend.aws_s3_bucket.terraform_state inves-terraform-state"

	cd ./resources/setup  ; \
		terraform init $(terraform-backend-config) 
	cd ./resources/setup ; \
		terraform apply $(terraform-backend-vars) 

init:
	$(call check_defined, env, Please set the env to plan for. Supported environments are: global | dev | prod )

	cd $(env-resources) ; \
		terraform fmt ; \
		terraform workspace new $(value workspace) || true ; \
		terraform workspace select $(value workspace) ; \
		terraform init $(terraform-backend-config) $(terraform-env-vars)

yarn: 
		@echo "Doing base yarn install"
		#@yarn

dist: yarn
		$(call check_defined, env, Please set the env to plan for. Supported environments are: dev | prod )
		@echo "Building the environment"
		@yarn build
	
run: yarn
		$(call check_defined, env, Please set the env to plan for. Supported environments are: dev | prod )
		@yarn start
		
# Removing the dist step for now, since we're not doing any build steps on this		
deploy:
		$(call check_defined, env, Please set the env to plan for. Supported environments are: dev | prod )
		@aws s3 sync ./src s3://$(env).toybox.network/ --delete


# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
    	$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
    	$(error Undefined $1$(if $2, ($2))))