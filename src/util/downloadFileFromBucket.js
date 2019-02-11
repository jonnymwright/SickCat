const util = require('util');
const fs = require('fs');
const AWS = require('aws-sdk');

const s3 = new AWS.S3({ signatureVersion: 'v4' });

module.exports = (bucket, key, file, callback) => {
  if (!bucket.length || !key.length) {
    callback(new Error(util.format('Error! Bucket: %s and Key: %s must be defined', bucket, key)));
    return;
  }

  const decodedKey = decodeURIComponent(key);

  console.log('Attempting to download s3://%s/%s to %s', bucket, decodedKey, file);
  s3.getObject({
    Bucket: bucket,
    Key: decodedKey
  })
    .createReadStream()
    .pipe(fs.createWriteStream(file))
    .on('error', error => {
      console.log('Error downloading s3://%s/%s to %s', bucket, decodedKey, file);
      callback(error);
    })
    .on('close', () => {
      console.log('Downloaded s3://%s/%s to %s', bucket, decodedKey, file);
      callback(null, file);
    });
};
