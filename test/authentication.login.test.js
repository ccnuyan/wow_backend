import { expect } from 'chai';
import Helpers from '../lib/helper';

const helpers = new Helpers();
let pool = null;
let regResult = null;
const params = {
  username: 'ccnuyan',
  password: 'password',
};

describe('authentication', () => {
  before(async () => {
    pool = await helpers.initDb();
    return pool.query('select * from membership.register($1, $2, $3, $4, $5, $6)', [
      params.username,
      params.password,
      'CCNU',
      '2013012305',
      '严中华',
      'MALE',
    ]).then((res) => {
      regResult = res.rows[0];
      return regResult;
    });
  });

  describe('with a valid login', () => {
    let authResult = null;
    before(() => {
      return pool.query('select * from membership.authenticate($1, $2)', [params.username, params.password])
      .then((res) => {
        authResult = res.rows[0];
        return authResult;
      });
    });
    it('is successful', () => {
      expect(authResult.success).to.be.true;
    });
  });

  describe('invalid login', () => {
    let authResult = null;
    before(() => {
      return pool.query('select * from membership.authenticate($1, $2)', [params.username, 'password1'])
      .then((res) => {
        authResult = res.rows[0];
        return authResult;
      });
    });
    it('is not successful', () => {
      expect(authResult.success).to.be.false;
    });
  });

  describe('with a valid token', () => {
    let authResult = null;
    before(() => {
      return pool.query('select * from membership.authenticate_by_token($1)', [regResult.token])
      .then((res) => {
        authResult = res.rows[0];
        return authResult;
      });
    });
    it('is successful', () => {
      expect(authResult.success).to.be.true;
    });
  });
});
