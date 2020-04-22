# Terraform Tests

There are two types of tests in this folder.

1. A set of tests with `@google-cloud/storage`, which is a Node.js idiomatic client for Cloud Storage.

1. A set of tests with `Terratest`, which is a Go library that provides patterns and helper functions for testing infrastructure.

- Make sure that you have installed the required tools defined in `.tool-versions` in root directory via [`asdf`](https://asdf-vm.com/#/core-manage-asdf-vm)

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
1. `make test_node`: It runs Nodejs test files.
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
