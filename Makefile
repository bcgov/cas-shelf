.PHONY: install-asdf-tools
install-asdf-tools:
	@cat .tool-versions | cut -f 1 -d ' ' | xargs -n 1 asdf plugin-add || true
	@asdf plugin-update --all
	@bash ./.bin/import-nodejs-keyring.sh
	@#MAKELEVEL=0 is required because of https://www.postgresql.org/message-id/1118.1538056039%40sss.pgh.pa.us
	@MAKELEVEL=0 POSTGRES_EXTRA_CONFIGURE_OPTIONS='--with-libxml' asdf install
	@asdf reshim
	@pip install -r requirements.txt
	@asdf reshim

.PHONY: create-workspace
create-workspace:
	./bin/tf-create-workspace-if-not-exist.sh $(org) $(workspace)
	./bin/tf-upload-workspace-configuration.sh ./bcgov $(org)/$(workspace)

.PHONY: set-variables
set-variables:
	./bin/tf-set-variables.sh ./variables/ $(org) $(workspace)

.PHONY: add-env
add-env:
	./bin/tf-variable-add-to-set.sh $(workspace_id) envs $(env)

.PHONY: run
run:
	./bin/tf-run.sh $(workspace_id)
