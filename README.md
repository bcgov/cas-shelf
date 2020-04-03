# Google Cloud Storage - Terraform

Terraform script to create GCS buckets in Montreal region based on `namespace` and `application` variables passed in.
It creates 4 buckets, `dev`, `test`, `prod`, `tools` for each application.

## Steps

1. Download `Terraform` based on your operating system and architecture.

   - [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html 'Terraform Downloads')
   - or install via [`asdf`](https://asdf-vm.com/#/core-manage-asdf-vm) (the versions are defined in `.tool-versions`).

1. Select an existing project or create a new one to have the `project ID`.

1. Create a service account private key and download it as JSON format.

   - Go to `IAM & Admin`
   - GO to `Service accounts`
   - Create a `Service account` or select an exisiting one
   - Create a private key to download (`credentials.json`)

1. Set basic Terraform environment variables
   - [https://www.terraform.io/docs/commands/environment-variables.html#tf_var_name](https://www.terraform.io/docs/commands/environment-variables.html#tf_var_name 'Terraform TF_VAR_name')

```bash
export TF_VAR_credentials=service_account_key_filepath # required, eg) credentials.json
export TF_VAR_project_name=project-name # required
export TF_VAR_backend_bucket=backend-bucket-name # required
export TF_VAR_envs='["dev", "test", "prod", "tools"]' # optional, default to ["dev", "test", "prod", "tools"]
```

- Once application environment list is overridden via `TF_VAR_envs`, it will affect all other namespace sets.

1. Create an initial GCS bucket to store Terraform state files.

```bash
cd remote-state
terraform init
terraform apply -auto-approve
cd ..
```

1. Initialize a working directory and build or change infrastructure based on the configuration file `main.tf`.

   - Note that `init` command includes the backend configuration using required environment variables.

```bash
terraform init -backend-config="bucket=$TF_VAR_backend_bucket" -backend-config="credentials=$TF_VAR_credentials"
terraform apply -var="namespace=button" -var="application=cas" -auto-approve
```
