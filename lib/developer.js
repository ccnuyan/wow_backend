import fs from 'fs';
import path from 'path';
import glob from 'glob';
import Promise from 'bluebird';
import _ from 'lodash';

import config from '../package.json';
import { pg } from '../db/connector';

const versionRoot = config.version.replace(/\./g, '-');
const sourceDir = path.join(__dirname, '../sql/', versionRoot);

const install = async () => {
  const globPattern = path.join(sourceDir, '**/*.sql');

  // use nosort to ensure that init.sql is loaded first
  // https://github.com/isaacs/node-glob
  const files = glob.sync(globPattern);

  const sqls = [];

  files.forEach((file) => {
    const sql = fs.readFileSync(file, {
      encoding: 'utf-8',
    });
    if (!_.endsWith(path.parse(file).name, '.prod')) {
      sqls.push({
        file,
        sql,
      });
    }
  });

  let leader = Promise.resolve();

  sqls.forEach((sqlObject) => {
    leader = leader.then(() => {
      /* eslint-disable promise/no-nesting*/

      // http://bluebirdjs.com/docs/getting-started.html

      return Promise.delay(30).then(() => {
        return pg.query(sqlObject.sql)
        .then(() => {
          return console.log(`sql installed: ${path.relative(__dirname, sqlObject.file)}`); // eslint-disable-line
        })
        .catch((err) => {
          console.log(`*** error:${sqlObject.file} ***`); // eslint-disable-line
          console.log(err); // eslint-disable-line
          console.log(`*** error:${sqlObject.file} ***`); // eslint-disable-line
          process.exit(1);
        });
      });

      /* eslint-disable promise/no-nesting*/
    });
  });

  await leader.then(() => console.log('done')); // eslint-disable-line no-console
};

export default {
  install,
};

