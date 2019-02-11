const async = require('async');
const fs = require('fs');
const path = require('path');
const util = require('./util');

module.exports = callback => {
  async.each(
    process.env.VIRUS_DEFINITION_FILES.split(';'),
    (dbFile, next) => {
      const file = path.join('/tmp', dbFile);
      fs.exists(file, exists => {
        console.log('%s exists: %s', file, exists);
        if (!exists || process.env.FORCE_REDOWNLOAD) {
          util.downloadFileFromBucket(
            process.env.VIRUS_DEFINITION_BUCKET,
            dbFile,
            file,
            next
          );
        } else {
          next();
        }
      });
    },
    callback
  );
};
