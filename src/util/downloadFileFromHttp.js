const util = require('util');
const fs = require('fs');
const fse = require('fs-extra');
const request = require('request');

module.exports = function(downloadUrl, file, callback) {
  const fileStream = fs.createWriteStream(file);

  const closeStream = err => {
    if (err) {
      return fse.remove(file, error => {
        if (error) {
          return callback(error);
        }
        return callback(err);
      });
    }

    return callback(null, file);
  };

  fileStream.on('finish', closeStream);

  request
    .get(downloadUrl)
    .on('response', response => {
      console.log('Finished downloading %s. Response %j', file, response);
      if (response.statusCode !== 200) {
        throw new Error(util.format('Error: status code %d', response.statusCode));
      }
    })
    .on('error', err => {
      console.error('Error downloading %s: %s', downloadUrl, err);
      fileStream.removeListener('finish', closeStream.bind(null, err));
      callback(err);
    })
    .pipe(fileStream);
};
