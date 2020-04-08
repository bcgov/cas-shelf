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
	./tfe-scripts/tf-create-workspace-if-not-exist.sh $(org) $(workspace)
	./tfe-scripts/tf-upload-workspace-configuration.sh ./bcgov $(org)/$(workspace)

.PHONY: set-variables
set-variables:
	./tfe-scripts/tf-set-variables.sh ./variables/ $(org) $(workspace)

.PHONY: add-app
add-env:
	./tfe-scripts/tf-variable-add-to-set.sh $(workspace_id) apps $(env)

.PHONY: run
run:
	./tfe-scripts/tf-run.sh $(org) $(workspace)
