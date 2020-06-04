# Terraform Tests

There are two types of tests in this folder.

1. A set of tests with [@google-cloud/storage](https://www.npmjs.com/package/@google-cloud/storage), which is a Node.js idiomatic client for Cloud Storage.

1. A set of tests with [Terratest](https://terratest.gruntwork.io/), which is a Go library that provides patterns and helper functions for testing infrastructure.

- Make sure that you have installed the required tools defined in `.tool-versions` in root directory via [`asdf`](https://asdf-vm.com/#/core-manage-asdf-vm)

## Environment variables setup
- The two sets of tests require following environment variables for initial test environment setup and tests:
1. `TF_VAR_credentials`: JSON string containing GCP (Google Cloud Platform) service account key.
1. `TF_VAR_project_id`: the project id of the GCP (Google Cloud Platform) project to test on.

- There are three ways to set these environment variables:
1. Set the variables directly on command line
   ```bash
   export TF_VAR_credentials=<value>
   export TF_VAR_project_id=<value>
   ```
1. Create and set the values in `.env` file next in the current folder.
   ```
   TF_VAR_credentials=<value>
   TF_VAR_project_id=<value>
   ```
1. Download the Service Account key file named `credentials.json` in the current directory.
   - `Makefile` commands looks for this file and creates `.env` file if exists.
   - Since convert a service account key file to JSON string can be challenging, this method is the easiest way for setup.

## Nodejs Tests

This is a Nodejs Express example that connects to GCP (Google Cloud Platform) tests for the basic use-cases.

### Test Cases

within the privileged bucket, the service account can:

1. upload a file to the bucket
1. download a file from the bucket
1. delete the empty bucket (privileged one)

and the service account cannot:

1. upload a file to another bucket
1. create a new bucket within the project
1. delete the nonempty bucket (privileged one)

### Steps

1. `make setup`: It creates two new buckets with each scoped service account.
1. `make nodejs_test`: It runs Nodejs test files.
1. `make destroy`: It removes the two buckets with service accounts created for testing.
   - It is recommanded to run this after testing to avoid conflicts in case of local test `Terraform` state is deleted.

## Terratest

Terratest is a Go library that makes it easier to write automated tests for your infrastructure code.

### Test Cases

1. It should upload a file to my bucket.
1. It should fail to upload a file to another bucket.

### Steps

1. `make setup`: It creates two new buckets with each scoped service account.
1. `make dep`: It adds dependencies required for test files.
1. `make terratest`: It runs Terratest test files.
1. `make destroy`: It removes the two buckets with service accounts created for testing.
   - It is recommanded to run this after testing to avoid conflicts in case of local test `Terraform` state is deleted.
