.PHONY: create_workspace
create_workspace:
	./tfe-scripts/tf-create-workspace-if-not-exist.sh $(org) $(workspace)
	./tfe-scripts/tf-upload-workspace-configuration.sh ./bcgov $(org)/$(workspace)
	./tfe-scripts/tf-set-variables.sh ./variables/ $(org) $(workspace)

.PHONY: delete_workspace
delete_workspace:
	./tfe-scripts/tf-delete-workspace.sh $(org) $(workspace)

.PHONY: set_values
set_values:
	./tfe-scripts/tf-update-variable-values.sh ./.values $(org) $(workspace)

.PHONY: add_app
add_app:
	./tfe-scripts/tf-variable-add-to-set.sh $(workspace_id) namespace_apps $(app)

.PHONY: run
run:
	./tfe-scripts/tf-run.sh $(org) $(workspace)

.PHONY: destroy
destroy:
	./tfe-scripts/tf-run.sh $(org) $(workspace) --delete

.PHONY: install_asdf_tools
install_asdf_tools:
	@cat .tool-versions | cut -f 1 -d ' ' | xargs -n 1 asdf plugin-add || true
	@asdf plugin-update --all
	@bash ./.bin/import-nodejs-keyring.sh
	@#MAKELEVEL=0 is required because of https://www.postgresql.org/message-id/1118.1538056039%40sss.pgh.pa.us
	@MAKELEVEL=0 POSTGRES_EXTRA_CONFIGURE_OPTIONS='--with-libxml' asdf install
	@asdf reshim
	@pip install -r requirements.txt
	@asdf reshim
