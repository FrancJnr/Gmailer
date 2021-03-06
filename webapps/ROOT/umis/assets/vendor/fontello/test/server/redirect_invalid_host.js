'use strict';


const supertest = require('supertest');
const url       = require('url');


describe('Invalid host', function () {

  it('should redirect to default', function (done) {
    let port = url.parse(TEST.N.config.bind.default.mount).port;

    supertest(`http://127.0.0.1:${port}`)
      .get('/')
      .expect('Location', `http://localhost:${port}/`)
      .expect(302, done);
  });
});
