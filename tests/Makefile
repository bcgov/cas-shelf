SHELL := /usr/bin/env bash

MY_BUCKET_KEY = my_bucket_name
OTHER_BUCKET_KEY = other_bucket_name

MY_BUCKET = my-bucket
OTHER_BUCKET = other-bucket
ROOT_CREDENTIALS = ../credentials.json

SETUP_CONTEXT = -var="$(MY_BUCKET_KEY)=$(MY_BUCKET)" \
				-var="$(OTHER_BUCKET_KEY)=$(OTHER_BUCKET)" \
				-auto-approve

TEST_CONTEXT = -$(MY_BUCKET_KEY) '$(MY_BUCKET)' \
				-$(OTHER_BUCKET_KEY) '$(OTHER_BUCKET)' \
				-my_credentials_file_path '../../../keys/$(MY_BUCKET).json'

.PHONY: setup
setup:
	terraform init setup
	terraform apply $(SETUP_CONTEXT) setup

.PHONY: destroy
destroy:
	terraform destroy $(SETUP_CONTEXT) setup

.PHONY: dep
dep:
	go get github.com/gruntwork-io/terratest/modules/terraform
	go get github.com/stretchr/testify/assert

.PHONY: terratest
terratest: dep
terratest:
	go test ./terratest/test/ $(TEST_CONTEXT)

.PHONY: test-node
test-node:
	yarn --cwd ./nodejs
	yarn --cwd ./nodejs test
