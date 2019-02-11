const async = require('async');
const util = require('util');
const temp = require('temp');
const path = require('path');
const fs = require('fs');
const { downloadFileFromBucket, notifySns } = require('./util');
const scanFile = require('./scanFile');
const downloadClamscanDbFiles = require('./downloadClamscanDbFiles');

const processRecord = (record, callback) => {
  const bucket = record.s3.bucket.name;
  const { key } = record.s3.object;

  async.waterfall(
    [
      downloadFileFromBucket.bind(null, bucket, key, temp.path({ suffix: path.extname(key) })),
      (file, innerCallback) => {
        let stats = fs.statSync('/tmp/bytecode.cvd');
        console.log('/tmp/bytecode.cvd: %s', stats.size);
        stats = fs.statSync('/tmp/daily.cvd');
        console.log('/tmp/daily.cvd: %s', stats.size);
        stats = fs.statSync('/tmp/main.cvd');
        console.log('/tmp/main.cvd: %s', stats.size);
        innerCallback(null, file);
      },
      scanFile,
      (details, isInfected, next) => {
        const status = isInfected ? 'infected' : 'not infected';
        console.log(`File is ${status}, sending notification on : ${process.env.SNS_TOPIC_ARN}`);
        notifySns(
          process.env.SNS_TOPIC_ARN,
          JSON.stringify({
            bucket,
            key,
            status,
            details
          }),
          next
        );
      }
    ],
    callback
  );
};

module.exports = (event, context, callback) => {
  console.log('Reading options from event: %j', util.inspect(event, { depth: 5 }));

  if (typeof event.Records === 'undefined') {
    return callback(new Error(util.format('Unable to find event. Records event: %j', event)));
  }

  async.parallel(
    {
      downloadClamscanDbFiles
    },
    err => {
      if (err) {
        console.log('Failed to download clamscandb files. Exiting');
        return callback(err);
      }
      console.log('Downloaded clamscandb file sucessfully.');

      async.each(event.Records, processRecord, callback);
      return callback();
    }
  );
  return callback();
};
