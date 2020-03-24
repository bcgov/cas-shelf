package test

import (
	"flag"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var myBucketName = flag.String("my_bucket_name", "World", "Name of location to greet")
var otherBucketName = flag.String("other_bucket_name", "World", "Name of location to greet")
var myCredentialsFilePath = flag.String("my_credentials_file_path", "World", "Name of location to greet")

func TestTerraformUploadFileToMyBucket(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../scripts/gcp-upload-file",
		Vars: map[string]interface{}{
			"bucket_name":              *myBucketName,
			"my_credentials_file_path": *myCredentialsFilePath,
		},
	}

	terraform.Init(t, terraformOptions)
	terraform.Apply(t, terraformOptions)

	var testFileName = terraform.Output(t, terraformOptions, "test_file_name")
	defer terraform.Destroy(t, terraformOptions)

	assert.Equal(t, "test.txt", testFileName)
}

func TestTerraformUploadFileToOtherBucket(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../scripts/gcp-upload-file",
		Vars: map[string]interface{}{
			"bucket_name":              *otherBucketName,
			"my_credentials_file_path": *myCredentialsFilePath,
		},
	}

	terraform.Init(t, terraformOptions)

	if _, err := terraform.ApplyE(t, terraformOptions); err != nil {
		defer terraform.Destroy(t, terraformOptions)
		return
	}

	defer terraform.Destroy(t, terraformOptions)
	assert.FailNow(t, "This test should fail!")
}

func TestTerraformCreateNewBucket(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../scripts/gcp-create-bucket",
		Vars: map[string]interface{}{
			"my_credentials_file_path": *myCredentialsFilePath,
		},
	}

	terraform.Init(t, terraformOptions)

	if _, err := terraform.ApplyE(t, terraformOptions); err != nil {
		defer terraform.Destroy(t, terraformOptions)
		return
	}

	defer terraform.Destroy(t, terraformOptions)
	assert.FailNow(t, "This test should fail!")
}
