const Clamscan = require('clamscan');

const config = {
  remove_infected: false,
  quarantine_infected: false,
  scan_log: null,
  debug_mode: true,
  file_list: null,
  scan_recursively: false,
  testing_mode: true,
  clamscan: {
    path: '/var/task/bin/clamscan',
    db: '/tmp',
    scan_archives: true,
    active: true
  },
  clamdscan: {
    path: null,
    active: false
  },
  preference: 'clamscan'
};

const clamscan = new Clamscan(config);

module.exports = clamscan.is_infected.bind(clamscan);
