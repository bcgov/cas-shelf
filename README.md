# Google Cloud Storage - Terraform API-driven workflow

Terraform Enterprise API scripts located in folder `tfe-scripts` helps create a new workspace with the initial configuration, folder `bcgov`
and user-defined configure variables, folder `variables`.

## Steps

### Install Tools

1. Install [`asdf`](https://asdf-vm.com/#/core-manage-asdf-vm?id=install-asdf-vm).
1. Install required tools via `asdf` (the versions are defined in `.tool-versions`).

```bash
make install_asdf_tools
```

### Set TF Cloud Token as an environment variable

1. Create a new Team token via [`Settings > Teams > Team API Token`](https://app.terraform.io/app/thebuttonclan/settings/teams).

1. Set environment variable `TFC_TOKEN` for tfe scripts.

```bash
export TFC_TOKEN=<team-token>
```

### Create a new workspace and upload configuration files

```bash
make create_workspace org=my-team workspace=my-workspace
```

- It skips creating a new one if the specified name of workspace already exists.
- It compresses the main TF script folder `bcgov` and uploads to the workspace (non-VCS).
- It sets placeholder variables from `variables` folder.

### Set variable values

1. Copy `example.values` file to `.values` file.
1. Set each value in `.values` file.

   - `project_id` the project id of Google Cloud Platform
   - `credentials_private_key` the private_key of GCP service account credentials key
   - `credentials_client_email` the client_email of GCP service account credentials key
   - `kubernetes_host` the hostname of Openshift cluster
   - `kubernetes_token` the authentication token of Openshift cluster
     - Use [`Service Account Tokens`](https://docs.openshift.com/container-platform/3.5/rest_api/index.html#rest-api-serviceaccount-tokens) instead of `Session Tokens`, which is expiring within 24 hours by default.
   - `slug` the slug for Openshift cluster
   - `apps` the list of application names of Openshift cluster
   - `envs` the environment names of Openshift cluster, default to `["dev", "test", "prod", "tools"]`
   - Non-primitive data types must escape double quotes `"` > `\"`.
   - The GCP service account requires the roles `Storage Admin`, `Create Service Accounts`, `Delete Service Accounts`, and `Service Account Key Admin`.

1. Run TFE script to set the variables on TFC workspace.

```bash
make set_values org=my-team workspace=my-workspace
```

### Trigger Run command to performs a plan & apply

```bash
make run org=my-team workspace=my-workspace
```

- It sets `Apply Method` to `Auto apply` on workspace creation to skip manual user confirmations after planning in terms of API-driven run workflow.
