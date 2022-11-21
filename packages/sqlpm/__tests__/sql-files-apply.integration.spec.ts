import {
  join,
} from 'node:path';

import {
  DatabasePlatform,
  DatabasePurpose,
  RunActionDirectory,
} from '@sqlpm/types-ts';

import {
  dirRemove,
} from '@sqlpm/file-async-ts';

import {
  connectionBuild, connectionOpen,
} from '@sqlpm/postgresql-client-ts';

import {
  sqlFilesGenerate,
  sqlFilesApply,
} from '../src/index';
import { fakeTimers } from './support/fake-timers';

describe('sqlFilesApply', () => {
  fakeTimers();

  it('should apply all the files to the server', async () => {
    const destinationRoot = join(
      __dirname,
      'test-files',
      'node-package-with-schema-dependency',
    );

    const buildDirector = 'sql-build-test2';
    const destinationBuildFolder = join(buildDirector, 'build');

    const destinationResetFolder = join(buildDirector, 'reset');

    const cleanupFolder = join(destinationRoot, buildDirector);

    // clean up any prior runs (just in case)
    await dirRemove(cleanupFolder, { recursive: true, required: false });

    await sqlFilesGenerate(
      destinationBuildFolder,
      DatabasePurpose.Readwrite,
      DatabasePlatform.Postgresql,
      [
        RunActionDirectory.Prerun,
        RunActionDirectory.Run,
        RunActionDirectory.Postrun,
      ],
      undefined,
      destinationRoot,
    );

    // Since this is a reset, we need to change the order that the files
    // are generated starting from the top node and working down.
    await sqlFilesGenerate(
      destinationResetFolder,
      DatabasePurpose.Readwrite,
      DatabasePlatform.Postgresql,
      [
        RunActionDirectory.Reset,
      ],
      undefined,
      destinationRoot,
    );

    const connection = connectionBuild({
      host: 'localhost',
      port: 12549,
      user: 'postgres',
      password: 'localpassword',
      dbname: 'postgres',
      schema: 'schema',
    });

    await sqlFilesApply(
      destinationBuildFolder,
      connection,
      destinationRoot,
    );

    const sql = connectionOpen(connection);
    let schemaExists;
    try {
      schemaExists = await sql`
        SELECT COUNT(*) as schema_exits
        FROM information_schema.schemata
        WHERE schema_name = 'sqlpm_example';
      `;
    } finally {
      await sql.end({ timeout: 1 });
    }
    expect(schemaExists[0].schema_exits).toEqual('1');

    await sqlFilesApply(
      destinationResetFolder,
      connection,
      destinationRoot,
    );
    const sqlVerify = connectionOpen(connection);
    let schemaNoLongerExists;
    try {
      schemaNoLongerExists = await sqlVerify`
        SELECT COUNT(*) as schema_exits
        FROM information_schema.schemata
        WHERE schema_name = 'sqlpm_example';
      `;
    } finally {
      await sqlVerify.end({ timeout: 1 });
    }
    expect(schemaNoLongerExists[0].schema_exits).toEqual('0');
    // clean up
    await dirRemove(cleanupFolder, { recursive: true });
  });
});
