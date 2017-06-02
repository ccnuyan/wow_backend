import { expect } from 'chai';
import Helpers from '../lib/helper';

const helpers = new Helpers();
let pool = null;

const params = {
  username: 'newuser',
  password: 'password',
};


describe('registration', () => {
  before(async () => {
    pool = await helpers.initDb();
  });
  describe('with valid creds', () => {
    let regResult = null;
    before(async () => {
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
    it('is successful', () => {
      expect(regResult.success).to.be.true;
    });
    it('returns a new id', () => {
      expect(regResult.id).to.not.be.null;
    });
    it('return a role', () => {
      expect(regResult.role).to.equal(10);
    });
    it('returns correct username', () => {
      expect(regResult.username).to.equal(params.username);
    });
    it('return an token', () => {
      expect(regResult.token).to.exist;
    });
  });
  describe('trying an existing user', () => {
    let regResult = null;
    before(async () => {
      return pool.query('select * from membership.register($1, $2, $3, $4, $5, $6)', [
        params.username,
        params.password,
        'CCNU',
        '2013012305abc',
        '严中华',
        'MALE',
      ]).then((res) => {
        regResult = res.rows[0];
        return regResult;
      });
    });
    it('is not successful', () => {
      expect(regResult.success).to.be.false;
    });
  });
  describe('trying an existing student_id', () => {
    let regResult = null;
    before(async () => {
      return pool.query('select * from membership.register($1, $2, $3, $4, $5, $6)', [
        'testusername',
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
    it('is not successful', () => {
      expect(regResult.success).to.be.false;
    });
  });
});
