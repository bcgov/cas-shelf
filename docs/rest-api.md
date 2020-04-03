# REST API

This GCS provisioner API is a self-contained System (SCS) to maintain Google Cloud Platform (GCP) buckets and each service account with its `credentials key`. It also provides a GCS bucket's `credentials key` by applying a `Secret Object` to the requested `Openshift` resource.

## Concepts

### This REST API provides an endpoint to take a set of arguments, `slug`, `application`, `environment`, and `API Token`.

- The combination of `slug` and `environment` is the name of a `Openshift` project. eg) wksv3k-dev
- `application` is the name of a `Openshift` application within the project.
- `API Token` is a authorization key to verify the access to the `Openshift` project and the permission to apply `Secret Object` containing the GCS bucket's credentilas information.

### This REST API system contains `Terraform CLI` distribution binary with two main scripts to provision GCS buckets.

- A `Terraform` script to ensure an initial GCS bucket to store Terraform state files.

  - It runs only once the system is started.

- A `Terraform` script to ensure a set of GCS buckets to store files from each `Openshift` project.
  - It runs everytime a new bucket request made.
  - It takes two arguments:
    1. `List of bucket names`: it is updated for every request. eg) ["wksv3k-airflow-dev", "wksv3k-airflow-test", ...]
    1. `Index number of the target`: it is a sequence number of the requested bucket, and passed in to download the target `credentials key` file only.

### This REST API system connects to the GCS Terraform backend bucket to retrieve the JSON state file and get the list of bucket names.

- The GCS `Terraform` backend bucket, set by the first `Terraform` script on server starts, contains the current state of all GCP resources.
- The server could take a advantage on reading the state data to get the current bucket names instead of storing it in somewhere else.
- The server iterates a resource list of only one type to parse and create the bucket names.
  - The possible types are `google_storage_bucket`, `google_service_account`, `google_service_account_key`, `google_storage_bucket_iam_member`, and `local_file` based on the current `Terraform` script.
  - eg) a sample resource of type `local_file`, see `instances.filename` to parse the bucket name.
  ```
  {
     "mode": "managed",
     "type": "local_file",
     "name": "gc_file",
     "each": "list",
     "provider": "provider.local",
     "instances": [
       {
         "index_key": 0,
         "schema_version": 0,
         "attributes": {
           "content": "{...}",
           "content_base64": null,
           "directory_permission": "0777",
           "file_permission": "0777",
           "filename": "./keys/button-dev-airflow.json",
           "id": "...",
           "sensitive_content": null
         }
       },
       ...
       ]
   }
  ```
- The server creates an updated bucket names based on the request and pass the names into the main `Terraform` script to add/remove the target bucket with the related resources on GCP.

### This REST API system contains `Openshift CLI` distribution binary.

- Once the requested `credentials key` file is downloaded, it creates a `Secret Object` and apply it to the target `Openshift` resource.
- If `API Token` in the request is not valid to do this action on the requested resource, it will fail.
- Example of YAML Secret definition

```
apiVersion: v1
kind: Secret
metadata:
  name: test-secret
stringData:
  secret.properties: |-
    property1=valueA
    property2=valueB
```

### This REST API system serves one request at a time

- The REST API system contains two separate stand-alone CLIs, which are `Terraform CLI` and `Openshift CLI`.
- These two stand-alone CLIs shouldn't be interrupted when processing a request.
- For the reasons above, the server turns other requests down and sends a `503 Service Unavailable` if there is a ongoing process.
  - `503 Service Unavailable`: The server is currently unable to handle the request due to a temporary overloading or maintenance of the server. The implication is that this is a temporary condition which will be alleviated after some delay. If known, the length of the delay MAY be indicated in a Retry-After header. If no Retry-After is given, the client SHOULD handle the response as it would for a 500 response.

### This REST API takes essential environment variables to setup Terraform

- `project_id`: The project id of the GCP (Google Cloud Platform)
- `private_key`: The private key from the service account's key file.
- `client_email`: The client email key from the service account's key file.
- The system is responsible for creating a credentials file in JSON format for Terraform scripts.

```json
{
  "type": "service_account",
  "project_id": "project_id",
  "private_key": "-----BEGIN PRIVATE KEY-----\nhashed_service_account_private_key\n-----END PRIVATE KEY-----\n",
  "client_email": "service_account_client_email"
}
```

- A service account key file contains more fields, but `project_id`, `private_key`, and `client_email` are the ones being used to validate JWT.

### Example of a API consumer scenario

- The API client needs to make a request to the API endpoint before applying other build configurations.
- The client's build configurations should include a definition to mount the `Secret Object` to populate data in its pods.
- Example of YAML of a Pod Populating Files in a Volume with Secret Data

```
apiVersion: v1
kind: Pod
metadata:
  name: secret-example-pod
spec:
  containers:
    - name: secret-test-container
      image: busybox
      command: [ "/bin/sh", "-c", "cat /etc/secret-volume/*" ]
      volumeMounts:
          # name must match the volume name below
          - name: secret-volume
            mountPath: /etc/secret-volume
            readOnly: true
  volumes:
    - name: secret-volume
      secret:
        secretName: test-secret
  restartPolicy: Never
```

### References

- [Terraform - Google Cloud Platform](https://www.terraform.io/docs/providers/google/index.html 'Terraform - Google Cloud Platform')
- [Openshift Secrets Object](https://docs.openshift.com/container-platform/3.11/dev_guide/secrets.html#secrets-examples 'Secrets Object')
- [HTTP Status Codes](https://www.restapitutorial.com/httpstatuscodes.html 'HTTP Status Codes')
