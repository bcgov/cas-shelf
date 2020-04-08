# Google Cloud Storage - Terraform API-driven workflow

Terraform Enterprise API scripts located in folder `tfe-scripts` helps create a new workspace with the initial configuration, folder `bcgov`
and user-defined configure variables, folder `variables`.

## Steps

### Install Tools

1. Install [`asdf`](https://asdf-vm.com/#/core-manage-asdf-vm?id=install-asdf-vm).
1. Install required tools via `asdf` (the versions are defined in `.tool-versions`).

```bash
make install-asdf-tools
```

### Set TF Cloud Token as an environment variable

1. Create a new token via [`TFC User Settings > Tokens`](https://app.terraform.io/app/settings/tokens).
1. Set environment variable `TFC_TOKEN` for tfe scripts.

```bash
export TFC_TOKEN=...
```

### Create a new workspace and upload configuration files

```bash
make create-workspace org=my-team workspace=my-workspace
```

- It skips creating a new one if the specified name of workspace already exists.
- It compresses the main TF script folder `bcgov` and uploads to the workspace (non-VCS).

### Set variables

1. Copy `example.variables` folder to `variables` folder.
1. Set each value in the vairable files. `data.attributes.value`.

   - Non-primitive data types must escape double quotes `"` > `\"`.

1. Run TFE script to set the variables on TFC workspace.

```bash
make set-variables org=my-team workspace=my-workspace
```

### Trigger Run command to performs a plan & apply

```bash
make run workspace_id=ws-xxxxxx
```

- It sets `Apply Method` to `Auto apply` on workspace creation to skip manual user confirmations after planning in terms of API-driven run workflow.
