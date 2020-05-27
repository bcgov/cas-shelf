const fs = require('fs');
const assert = require('assert');
const AssertionError = require('assert').AssertionError;

const rm = path => fs.existsSync(path) && fs.unlinkSync(path);

let ctx;

beforeEach(async function() {
  ctx = await require('./core')();
});

describe('GCS Upload File', function() {
  const filename = 'test.txt';

  it(`should upload '${filename}' to the scoped bucket`, async function() {
    if (!fs.existsSync(filename)) fs.writeFileSync(filename, 'test content');
    const result = await ctx.uploadFile({ filename });
    assert.strictEqual(result.success, true);
    rm(filename);
  });

  it(`should fail to upload '${filename}' to another bucket`, async function() {
    if (!fs.existsSync(filename)) fs.writeFileSync(filename, 'test content');
    const result = await ctx.uploadFile({ filename, bucketName: ctx.otherBucketName });
    assert.strictEqual(result.success, false);
    console.log(result.message);
    assert.strictEqual(result.message.indexOf('does not have storage.objects.create access to') > -1, true);
    rm(filename);
  });
});

describe('GCS Download File', function() {
  const srcFilename = 'test.txt';
  const dummySrcFilename = 'dummy.txt';
  const destFilename = 'downloaded.txt';

  it(`should download '${srcFilename}' to '${destFilename}'`, async function() {
    rm(destFilename);
    const result = await ctx.downloadFile({ srcFilename, destFilename });
    assert.strictEqual(result.success, true);
    rm(destFilename);
  });

  it(`should fail to download '${dummySrcFilename}' to '${destFilename}'`, async function() {
    rm(destFilename);
    const result = await ctx.downloadFile({ srcFilename: dummySrcFilename, destFilename });
    assert.strictEqual(result.success, false);
    console.log(result.message);
    assert.strictEqual(result.message.indexOf('No such object') > -1, true);
    rm(destFilename);
  });
});

describe('GCS Create Bucket', function() {
  const bucketName = 'my-bucket-' + new Date().getTime();

  it(`should fail to create a new bucket '${bucketName}' to GCS`, async function() {
    const result = await ctx.createBucket({ bucketName });
    assert.strictEqual(result.success, false);
    console.log(result.message);
    assert.strictEqual(result.message.indexOf('does not have storage.buckets.create access') > -1, true);
  });
});

describe('GCS Delete Bucket', function() {
  it(`should fail to delete the nonempty scoped bucket`, async function() {
    const result = await ctx.deleteBucket();
    assert.strictEqual(result.success, false);
    console.log(result.message);
    assert.strictEqual(result.message.indexOf('The bucket you tried to delete was not empty') > -1, true);
  });

  const filename = 'test.txt';
  it(`should delete '${filename}' from the scoped bucket`, async function() {
    const result = await ctx.deleteFile({ filename });
    assert.strictEqual(result.success, true);
  });

  it(`should delete the empty scoped bucket`, async function() {
    const result = await ctx.deleteBucket();
    assert.strictEqual(result.success, true);
  });
});
