import {
  join,
} from 'node:path';

import {
  connectionBuild,
  databaseCreate,
  databaseDrop,
} from '@sqlpm/postgresql-client-ts';
import { DatabasePlatform, DatabasePurpose, RunActionDirectory } from '@sqlpm/types-ts';
import { dirRemove } from '@sqlpm/file-async-ts';
import { sqlFilesGenerate } from './sql-files-generate';
import { sqlFilesApply } from './sql-files-apply';

/**
 * The path to the child most package.json file.
 * @param path
 */
export const sqlTestPackage = async (
  packagePath: string,
  databaseName: string,
  keepGenerated: boolean = false,
): Promise<boolean> => {
  let result = true;
  const destinationRoot = packagePath || __dirname;
  const scriptDirectory = 'sqlpm-test';
  let errorDuringTesting = false;
  const cleanupFolder = join(destinationRoot, scriptDirectory);

  // Uses the environment variables to get an initial connection
  const primaryConnection = connectionBuild();
  const newConnection = {
    ...primaryConnection,
    database: databaseName,
  };

  // CLEANUP Database amd files
  await databaseDrop(databaseName, primaryConnection);

  // Let's clean up any prior tests as they may have failed and we around
  // the sql script so a developer can see what the issue was
  await dirRemove(cleanupFolder, { recursive: true, required: false });

  // We need to create a database to run our tests in.
  await databaseCreate(databaseName, primaryConnection);

  // TODO: This should all be configured
  const destinationBuildFolder = join(scriptDirectory, 'build');
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

  const destinationResetFolder = join(scriptDirectory, 'reset');
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

  const destinationTestFolder = join(scriptDirectory, 'test');
  await sqlFilesGenerate(
    destinationTestFolder,
    DatabasePurpose.Readwrite,
    DatabasePlatform.Postgresql,
    [
      RunActionDirectory.Seed,
      RunActionDirectory.Test,
    ],
    undefined,
    destinationRoot,
  );

  try {
    try {
      // build the schema
      await sqlFilesApply(
        destinationBuildFolder,
        newConnection,
        destinationRoot,
      );

      // run the tests
      await sqlFilesApply(
        destinationTestFolder,
        newConnection,
        destinationRoot,
      );
      // tear down the entire thing
      await sqlFilesApply(
        destinationResetFolder,
        newConnection,
        destinationRoot,
      );
    } catch (err) {
      const error = err as Error;

      if (error.name !== 'PostgresError') {
        // TODO: Work on logging the error
        // eslint-disable-next-line no-console
        console.log(error.name);
        // eslint-disable-next-line no-console
        console.log(error.message);
      }
      errorDuringTesting = true;
      result = false;
    } finally {
      if (errorDuringTesting === false && keepGenerated === false) {
        await databaseDrop(databaseName, primaryConnection);
      }
    }
  } finally {
    if (errorDuringTesting === false && keepGenerated === false) {
      // We need to destroy the database once the tests have run.
      await dirRemove(cleanupFolder, { recursive: true, required: false });
    }
  }

  return result;
};
