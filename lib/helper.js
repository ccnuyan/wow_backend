import { pg } from '../db/connector';
import developer from '../lib/developer';

function Helpers() {
  this.initDb = async () => {
    let pool = null;
    try {
      // drop all the user records
      // this will cascade to everything else
      // the only time this will fail is on very first run
      // otherwise the DB should always be there
      pool = await pg.connect();
      await developer.install();
    // now load up whatever SQL we want to run
    } catch (err) {
      console.log(err); // eslint-disable-line no-console
    }
    // return a new Massive instance
    return pool;
  };
}

export default Helpers;
