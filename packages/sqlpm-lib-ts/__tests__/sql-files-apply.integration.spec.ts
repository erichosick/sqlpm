import {
  join,
} from 'node:path';

import {
  DatabaseSystem,
  DatabaseAccessMode,
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
import { fakeTimers } from '../src/fake-timers';

describe('sqlFilesApply', () => {
  fakeTimers();

  it('should apply all the files to the server', async () => {
    const destinationRoot = join(
      __dirname,
      'test-files',
      'node-package-with-schema-dependency',
    );

    const databaseName = 'sqlpm-test-db-01';

    const destinationBuildFolder = join('build');

    const destinationResetFolder = join('reset');

    const cleanupFolder = join(destinationRoot, databaseName);

    // clean up any prior runs (just in case)
    await dirRemove(cleanupFolder, { recursive: true, required: false });

    await sqlFilesGenerate(
      databaseName,
      destinationBuildFolder,
      DatabaseAccessMode.ReadWrite,
      DatabaseSystem.Postgresql,
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
      databaseName,
      destinationResetFolder,
      DatabaseAccessMode.ReadWrite,
      DatabaseSystem.Postgresql,
      [
        RunActionDirectory.Reset,
      ],
      undefined,
      destinationRoot,
    );

    // using environment variables set when tests were called
    const connection = connectionBuild();

    await sqlFilesApply(
      databaseName,
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
      databaseName,
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
