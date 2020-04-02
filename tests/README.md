# Terratest

This is a Nodejs Express example that connects to GCP (Google Cloud Platform) tests for the basic use-cases.

## Pre-requisite

- [`Nodejs`](https://nodejs.org/en/download/)
- [`Yarn`](https://classic.yarnpkg.com/en/docs/install/#debian-stable)
- install via [`asdf`](https://asdf-vm.com/#/core-manage-asdf-vm), (the versions are defined in `.tool-versions` in root directory).

## Test Cases

within the privileged bucket, the service account can:

1. upload a file to the bucket
1. download a file from the bucket
1. delete the empty bucket (privileged one)

and the service account cannot:

1. upload a file to another bucket
1. create a new bucket within the project
1. delete the nonempty bucket (privileged one)

## Steps

```bash
yarn
yarn test
```
