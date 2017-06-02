import { expect } from 'chai';
import Helpers from '../lib/helper';
// http://chaijs.com/api/bdd/
const helpers = new Helpers();
let pool = null;

describe('pool', () => {
  before(async () => {
    pool = await helpers.initDb();
  });

  it('not null', () => {
    expect(pool).to.not.be.null;
  });
});
