import {
  join,
} from 'node:path';

import {
  buildDependency,
} from '../src/index';

describe('build', () => {
  describe('buildDependency', () => {
    it(`should have a packageDatabase configured in a sqlpm
      property of package.json`, async () => {
      const nodePackage = await buildDependency(
        join(
          __dirname,
          'test-files',
          'node-package-with-package-database',
        ),
      );

      expect(nodePackage?.package.sqlpm).toEqual({
        packageDatabase: {
          databaseName: 'db_cron',
        },
      });
    });
  });
});
