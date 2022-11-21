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
  pathExists,
} from '@sqlpm/file-async-ts';

import {
  sqlFilesGenerate,
} from '../src/index';

describe('sqlFilesGenerate', () => {
  it('should pull in all the sql files', async () => {
    const testDir = join(
      __dirname,
      'test-files',
      'node-package-with-schema-dependency',
    );

    const buildDirector = 'sql-build-test';
    const destinationFolder = join(buildDirector, 'build');
    await sqlFilesGenerate(
      destinationFolder,
      DatabasePurpose.Readwrite,
      DatabasePlatform.Postgresql,
      [
        RunActionDirectory.Prerun,
        RunActionDirectory.Run,
        RunActionDirectory.Postrun,
      ],
      undefined,
      testDir,
    );

    const absoluteDestinationFolder = join(testDir, destinationFolder);

    // It should have create the destination folder
    const exists = await pathExists(absoluteDestinationFolder);
    expect(exists).toEqual(true);

    expect(
      await pathExists(
        join(
          absoluteDestinationFolder,
          '00010_prerun_@sqlpm-sqlpm-example-postgresql_v0-0-0.sql',
        ),
      ),
    ).toEqual(true);

    expect(
      await pathExists(
        join(
          absoluteDestinationFolder,
          '00020_run_@sqlpm-sqlpm-example-postgresql_v0-0-0.sql',
        ),
      ),
    ).toEqual(true);

    expect(
      await pathExists(
        join(
          absoluteDestinationFolder,
          '00030_postrun_@sqlpm-sqlpm-example-postgresql_v0-0-0.sql',
        ),
      ),
    ).toEqual(true);

    // clean up
    const cleanupFolder = join(testDir, buildDirector);
    await dirRemove(cleanupFolder, { recursive: true });
  });
});
