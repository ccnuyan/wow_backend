import postgres from 'pg';
import config from '../config';

// export const massive = massivePostgres.loadSync(config.massive);
export const pg = new postgres.Pool(config.pg);
export default {
  pg,
};
