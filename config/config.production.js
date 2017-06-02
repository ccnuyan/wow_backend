export default {
  mode: 'production',
  pg: {
    user: 'postgres',
    database: 'backend-boilerplate',
    password: 'admin',
    host: 'localhost',
    port: 32768,
    max: 10,
    idleTimeoutMillis: 30000,
  },
};
