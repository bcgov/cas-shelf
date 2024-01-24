# ⚠️ This repository is now deprecated ⚠️

Please see [cas-pipeline](http://www.github.com/bcgov/cas-pipeline) for a comparable Terraform flow.

> Due to changes to Terraform Cloud plans, we have moved away from using it as our runner and state store. Each repo will handle it's own state and runs. See more information in [cas-pipeline](http://www.github.com/bcgov/cas-pipeline) for our Terraform usage patterns.

# Google Cloud Storage - Terraform API-driven workflow

Terraform Enterprise API scripts located in folder `tfe-scripts` helps create a new workspace with the initial configuration, folder `bcgov`
and user-defined configure variables, folder `variables`.

## Status

![Lifecycle:Deprecated](https://img.shields.io/badge/Lifecycle-Deprecated-red)

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

### Create a Google Application Service Account key for GCS and get the Credentials file

1. Navigate to the Google Cloud Platform API Console.
1. Select a project or create a new project.
1. Navigate to IAM & Admin > Service Accounts page.
1. Select a Service Account or create a new Service Account.
   - The Service Account requires the roles `Storage Admin`, `Create Service Accounts`, `Delete Service Accounts`, and `Service Account Key Admin`.
1. Create a Service Account key as JSON and download it named `credentials.json` in the root directory.

### Create a new workspace and upload configuration files

```bash
make create_workspace org=<my-team> workspace=<my-workspace>
```

- It skips creating a new one if the specified name of workspace already exists.
- It compresses the main TF script folder `bcgov` and uploads to the workspace (non-VCS).
- It sets placeholder variables from `variables` folder.

### Set variable values

1. Copy `example.values` file to `.values` file.
1. Set each value in `.values` file.

   - `credentials_file`: the credentials file path of Google Cloud service account
   - `kubernetes_host`: the hostname of Openshift cluster
   - `kubernetes_token`: the authentication token of Openshift cluster
     - Use [`Service Account Tokens`](https://docs.openshift.com/container-platform/3.11/rest_api/index.html#rest-api-serviceaccount-tokens) instead of `Session Tokens`, which is expiring within 24 hours by default.
   - `kubernetes_namespaces`: the list of Openshift namespaces to run jobs
   - `namespace_apps`: the list of namespace and app name pairs of Openshift cluster

1. Run TFE script to set the variables on TFC workspace.

```bash
make set_values org=<my-team> workspace=<my-workspace>
```

### Trigger Run command to performs a plan & apply

```bash
make run org=<my-team> workspace=<my-workspace>
```

- It sets `Apply Method` to `Auto apply` on workspace creation to skip manual user confirmations after planning in terms of API-driven run workflow.

### Other commands

```bash
make sync_values org=<my-team> workspace=<my-workspace> # it downloads the current variable values from the workspace
make destroy org=<my-team> workspace=<my-workspace> # it destroys all resources created by the workspace
make delete_workspace org=<my-team> workspace=<my-workspace> # it deletes the workspace
```

- `sync_values` command is useful to sync variable `namespace_apps` value because it gets updated during deployment process.
- It is highly recommended to run `destroy` command to remove resources before deleting a workspace.

### Kubernetes Service Account Token

If you are not familier with creating `Role`, `Service Account`, and `Role Binding` to assign the roles to the service account with `oc, kubectl` commands, there is a separate Terraform script to help create the OCP service account and produce its token.

1. Navigate to the folder.

```bash
cd secret-admin-sa
```

2. Create a Terraform variable file based off the example file.

```bash
cp terraform.tfvars.example terraform.tfvars
```

3. Set the values in the variable file.

   - `kubernetes_token`: the authentication token that has privileges to create resources, `Role`, `Service Account`, and `Role Binding`, on the target namespaces.
   - `kubernetes_host`: the hostname of Openshift cluster
   - `kubernetes_role_namespaces`: the array of OCP namespaces to create the `Role`s, and `Role Binding`s on.
   - `kubernetes_service_account_namespace`: the OCP namespace to create the `Service Account` on.

4. Initialize Terrafrom and provision the resources.

```bash
terraform init
terraform apply -auto-approve
```

5. Once completed successfully, it will prompt the service account information.

```bash
Apply complete! Resources: ⬜ added, 0 changed, 0 destroyed.

Outputs:

service_account_name = <namespace>/<service_account_name>
service_account_token = <service_account_token>
```

- The service account will have minimum privileges to support the main Terraform script.
- Note that it will create Terraform state data in your local machine.

### How to provision a new bucket for a new app during deployment process

- In the process of setting variable values `.values`, it also creates Secret Objects containing Terraform Cloud workspace credentials in each Openshift namespace.
- In Github tag push events, CI (CircleCI) publishes images encapsulating one of the TFC API script to provision a new app.
  - https://github.com/bcgov/cas-shelf/packages/193931
- There is `kubernetes job task` in a sub-directory `openshift` > `deploy` > `job`, which runs the image on Openshift cluster using the TFC workspace Secret Objet.
  - it requires one string argument includes namespace and app name separated by comma, `"namespace,app"` in `command` job attribute.

### Docker image tag convention

- It uses Sementic Versioning [`SemVer`](https://semver.org/) in order to attach a meaning to a version number or the change.
- It publishes 4(+) different versions of images based on `Git Tag` to support flexible `version range` to users.
  - e.g. `git tag 1.2.3-rc2`
    - `<image-url>:1`
    - `<image-url>:1.2`
    - `<image-url>:1.2.3`
    - `<image-url>:1.2.3-rc2`
    - Image tags above point at the same image after pushing them.
