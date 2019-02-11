import childProcessPromise from 'child-process-promise';
import { S3 } from 'aws-sdk';
import fs from 'fs';

const s3 = S3();
const writeNewDefinitionsToS3 = async () => {
  await childProcessPromise.execFile('./bin/freshclam', ['-u', 'ec2-user', '--datadir=/tmp/']);

  const promises = ['bytecode.cvd', 'daily.cvd', 'main.cvd', 'mirrors.dat'].map(fileName =>
    s3
      .putObject({
        Bucket: process.env.S3_BUCKET,
        Key: fileName,
        Body: fs.createReadStream(`/tmp/${fileName}`)
      })
      .promise()
  );
  await Promise.all(promises);
};

const handleUpdateVirusDefinitions = async () => {
  try {
    await writeNewDefinitionsToS3();
    return {
      statusCode: 200,
      message: 'Success'
    };
  } catch (err) {
    return {
      statusCode: 500,
      message: err.message
    };
  }
};

exports.handler = handleUpdateVirusDefinitions;
