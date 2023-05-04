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
  pathExists,
} from '@sqlpm/file-async-ts';

import { loadNodePackage } from '@sqlpm/node-package-ts';
import {
  packageFileNameVersion,
  sqlFilesGenerate,
} from '../src/index';

describe('sqlFilesGenerate', () => {
  it('should pull in all the sql files', async () => {
    const testDir = join(
      __dirname,
      'test-files',
      'node-package-with-schema-dependency',
    );

    const destinationFolder = join('build');
    const databaseName = 'sqlpm-test-db-02';
    await sqlFilesGenerate(
      databaseName,
      destinationFolder,
      DatabaseAccessMode.ReadWrite,
      DatabaseSystem.Postgresql,
      [
        RunActionDirectory.Prerun,
        RunActionDirectory.Run,
        RunActionDirectory.Postrun,
      ],
      undefined,
      testDir,
    );

    const absoluteDestinationFolder = join(
      testDir,
      databaseName,
      destinationFolder,
    );

    // It should have create the destination folder
    const exists = await pathExists(absoluteDestinationFolder);
    expect(exists).toEqual(true);

    const examplePackage = await loadNodePackage(
      join(
        __dirname,
        '..',
        '..',
        '..',
        'schemas',
        'postgresql',
        'sqlpm-example',
        'package.json',
      ),
    );

    const version = examplePackage?.content.version;
    expect(version).toBeDefined();

    const fileNameVersion = packageFileNameVersion(version as string);
    expect(
      await pathExists(
        join(
          absoluteDestinationFolder,
          `00010_prerun_@sqlpm-sqlpm-example-postgresql_v${fileNameVersion}.sql`,
        ),
      ),
    ).toEqual(true);

    expect(
      await pathExists(
        join(
          absoluteDestinationFolder,
          `00020_run_@sqlpm-sqlpm-example-postgresql_v${fileNameVersion}.sql`,
        ),
      ),
    ).toEqual(true);

    expect(
      await pathExists(
        join(
          absoluteDestinationFolder,
          `00030_postrun_@sqlpm-sqlpm-example-postgresql_v${fileNameVersion}.sql`,
        ),
      ),
    ).toEqual(true);

    // clean up
    const cleanupFolder = join(testDir, databaseName);
    await dirRemove(cleanupFolder, { recursive: true });
  });
});
