const util = require('util');
const url = require('url');
const validUrl = require('valid-url');
const downloadFileFromBucket = require('./downloadFileFromBucket');
const downloadFileFromHttp = require('./downloadFileFromHttp');

module.exports = (downloadUrl, file, callback) => {
  /* jscs:disable */
  if (!validUrl.is_uri(downloadUrl)) {
    /* jscs:enable */
    return callback(new Error(util.format('Error: Invalid uri %s', downloadUrl)));
  }

  console.log('Downloading %s to %s', downloadUrl, file);

  const parsedUrl = url.parse(downloadUrl);

  switch (parsedUrl.protocol) {
    case 's3:': {
      return downloadFileFromBucket(
        parsedUrl.hostname,
        parsedUrl.pathname.slice(1),
        file,
        callback
      );
    }

    default: {
      return downloadFileFromHttp(downloadUrl, file, callback);
    }
  }
};
