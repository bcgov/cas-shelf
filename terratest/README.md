# Terratest

Terratest is a Go library that makes it easier to write automated tests for your infrastructure code.

## Pre-requisite

- [`Golang`](https://golang.org/doc/install) or install via [`asdf`](https://asdf-vm.com/#/core-manage-asdf-vm) (the versions are defined in `.tool-versions` in root directory).

## Test Cases

1. It should upload a file to my bucket.
1. It should fail to upload a file to another bucket.

## Steps

1. `make setup`: It creates two new buckets with each scoped service account.
1. `make dep`: It adds dependencies required for test files.
1. `make test`: It runs test files.
1. `make destroy`: It removes the two buckets with service accounts created for testing.
   - It is recommanded to run this after testing to avoid conflicts in case of local test `Terraform` state is deleted.
