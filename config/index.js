import development from './config.development';
import production from './config.production';

const config = process.env.NODE_ENV && process.env.NODE_ENV.trim() === 'production' ? production : development;

console.log(`running in ${config.mode} mode`); // eslint-disable-line no-console

export default config;
