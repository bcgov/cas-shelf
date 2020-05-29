const fs = require('fs');
const path = require('path');
const util = require('util');
const { Storage } = require('@google-cloud/storage');

const statAsync = util.promisify(fs.stat);
const readdirAsync = util.promisify(fs.readdir);
const readfileAsync = util.promisify(fs.readFile);

const projectId = process.env.TF_VAR_project_id;;

const KEY_DIRECTORY = '../keys';
const BUCKET_PREFIX_FILE = '../test-bucket-prefix';

module.exports = async ({ logSuccess = false, logError = false } = {}) => {
  const stat = await statAsync(KEY_DIRECTORY);
  if (!stat || !stat.isDirectory()) return;

  const keyNames = await readdirAsync(KEY_DIRECTORY);
  const keyPaths = keyNames.map(key => path.join(KEY_DIRECTORY, key));
  const keyPath1 = keyPaths[0];
  const keyPath2 = keyPaths[1];

  const prefix = await readfileAsync(BUCKET_PREFIX_FILE, 'utf8');
  const getBucketName = keypath => `${prefix}-${path.basename(keypath, '.json')}`;

  const myBucketName = getBucketName(keyPath1);
  const otherBucketName = getBucketName(keyPath2);

  // Creates a client from a Google service account key.
  const storage = new Storage({ keyFilename: keyPath1, projectId });

  async function uploadFile({ filename = 'test.txt', bucketName = myBucketName } = {}) {
    try {
      await storage.bucket(bucketName).upload(filename, {
        // Support for HTTP requests made with `Accept-Encoding: gzip`
        gzip: true,
        // By setting the option `destination`, you can change the name of the
        // object you are uploading to a bucket.
        metadata: {
          // Enable long-lived HTTP caching headers
          // Use only if the contents of the file will never change
          // (If the contents will change, use cacheControl: 'no-cache')
          cacheControl: 'public, max-age=31536000',
        },
      });

      if (logSuccess) console.log(`${filename} uploaded to ${bucketName}.`);
      return { success: true };
    } catch (err) {
      if (logError) console.error(err);
      return { success: false, message: err.message || err };
    }
  }

  async function downloadFile({
    destFilename = 'downloaded.txt',
    srcFilename = 'test.txt',
    bucketName = myBucketName,
  } = {}) {
    const options = {
      destination: destFilename,
    };

    try {
      await storage
        .bucket(bucketName)
        .file(srcFilename)
        .download(options);

      if (logSuccess) console.log(`gs://${bucketName}/${srcFilename} downloaded to ${destFilename}.`);
      return { success: true };
    } catch (err) {
      if (logError) console.error(err);
      return { success: false, message: err.message || err };
    }
  }

  async function createBucket({ bucketName = 'my-bucket' }) {
    // See https://cloud.google.com/storage/docs/locations for more information
    // https://cloud.google.com/storage/docs/storage-classes for more information
    try {
      const [bucket] = await storage.createBucket(bucketName, {
        location: 'NORTHAMERICA-NORTHEAST1',
        storageClass: 'STANDARD',
      });

      if (logSuccess) console.log(`Bucket ${bucket.name} created.`);
      return { success: true };
    } catch (err) {
      if (logError) console.error(err);
      return { success: false, message: err.message || err };
    }
  }

  async function deleteBucket({ bucketName = myBucketName } = {}) {
    try {
      await storage.bucket(bucketName).delete();

      if (logSuccess) console.log(`Bucket ${bucketName} deleted.`);
      return { success: true };
    } catch (err) {
      if (logError) console.error(err);
      return { success: false, message: err.message || err };
    }
  }

  async function deleteFile({ filename = 'my-bucket', bucketName = myBucketName }) {
    try {
      await storage
        .bucket(bucketName)
        .file(filename)
        .delete();

      if (logSuccess) console.log(`gs://${bucketName}/${filename} deleted.`);
      return { success: true };
    } catch (err) {
      if (logError) console.error(err);
      return { success: false, message: err.message || err };
    }
  }

  return {
    uploadFile,
    downloadFile,
    deleteFile,
    createBucket,
    deleteBucket,
    myBucketName,
    otherBucketName,
  };
};
