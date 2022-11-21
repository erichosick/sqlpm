// TODO: Decouple pino from the library
// import pino from 'pino';
// const logger = pino(pino.destination('/dev/null')); // pino null for testing

import {
  connectionOpen,
  connectionBuild,
} from '../src/index';

import {
  fakeTimers,
} from './support/fake-timers';

describe('createConnection', () => {
  fakeTimers();

  describe('errors', () => {
    it('connection invalid: it should not find the host', async () => {
      const connection = connectionBuild({
        host: 'host', // host is not valid
        port: 12549,
        user: 'postgres',
        password: 'localpassword',
        dbname: 'postgres',
        schema: 'schema',
      });
      expect(connection).toBeDefined();

      const sql = connectionOpen(connection);

      let error: Error | null = null;
      try {
        await sql`SELECT 1 as num;`;
      } catch (err: unknown) {
        // Note: err instance Of Error is false
        error = err as Error;
      }

      expect(error?.message).toEqual('getaddrinfo ENOTFOUND host');
    });
  });

  describe('connect', () => {
    it('connection valid', async () => {
      const connection = connectionBuild({
        host: 'localhost',
        port: 12549,
        user: 'postgres',
        password: 'localpassword',
        dbname: 'postgres',
        schema: 'schema',
      });
      expect(connection).toBeDefined();
      const sql = connectionOpen(connection);

      let selectResult;
      try {
        selectResult = await sql`SELECT 1 as num;`;
      } finally {
        await sql.end({ timeout: 1 });
      }

      expect(selectResult).toEqual([{ num: 1 }]);
    });
  });
});
