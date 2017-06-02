export default {
  mode: 'development',
  pg: {
    user: 'postgres',
    database: 'wow_backend_dev',
    password: 'admin',
    host: 'localhost',
    port: 32768,
    max: 10,
    idleTimeoutMillis: 30000,
  },
};
