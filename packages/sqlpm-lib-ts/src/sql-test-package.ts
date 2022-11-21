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
) => {
  const destinationRoot = packagePath || __dirname;
  const scriptDirectory = '.sqlpm-test';

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

  const destinationTestFolder = join(scriptDirectory, 'test');
  // Since this is a reset, we need to change the order that the files
  // are generated starting from the top node and working down.
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

  // Uses the environment variables to get an initial connection
  const validConnection = connectionBuild();
  try {
    try {
    // We need to create a database to run our tests in.
      await databaseCreate(databaseName, validConnection);
      const newConnection = {
        ...validConnection,
        dbName: databaseName,
      };

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
      } finally {
        // tear down the entire thing
        await sqlFilesApply(
          destinationResetFolder,
          newConnection,
          destinationRoot,
        );
      }
    } catch (err) {
      const error = err as Error;

      // TODO: Use a real logger at some point
      // eslint-disable-next-line no-console
      console.log(error.message);
    } finally {
      await databaseDrop(databaseName, validConnection);
    }
  } finally {
  // We need to destroy the database once the tests have run.
    const cleanupFolder = join(destinationRoot, scriptDirectory);
    await dirRemove(cleanupFolder, { recursive: true });
  }
};
