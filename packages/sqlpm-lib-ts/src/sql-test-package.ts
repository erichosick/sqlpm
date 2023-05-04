import {
  join,
} from 'node:path';

import {
  connectionBuild,
  databaseCreate,
  databaseDrop,
  DatabaseDropOptions,
} from '@sqlpm/postgresql-client-ts';
import { DatabaseSystem, DatabaseAccessMode, RunActionDirectory } from '@sqlpm/types-ts';
import { dirRemove } from '@sqlpm/file-async-ts';
import { sqlFilesGenerate } from './sql-files-generate';
import { sqlFilesApply } from './sql-files-apply';

export interface SqlTestPackageOptions extends DatabaseDropOptions{

  /**
   * When true, any assets generated during the test are kept around including
   * the database and SQL scripts. When false, the assets are removed unless
   * the test errored. Default is false.
   */
  keepGenerated?: boolean;

}

/**
 * The path to the child most package.json file.
 * @param path
 */
export const sqlTestPackage = async (
  packagePath: string,
  databaseName: string,
  options?: SqlTestPackageOptions,
): Promise<boolean> => {
  let result = true;
  const keepGenerated = options?.keepGenerated ? options?.keepGenerated : false;
  const scriptDirectory = 'sqlpm-test';
  const destinationRoot = join(packagePath || __dirname, scriptDirectory);
  let errorDuringTesting = false;
  const cleanupFolder = join(destinationRoot);
  // Uses the environment variables to get an initial connection
  const primaryConnection = connectionBuild();
  const newConnection = {
    ...primaryConnection,
    database: databaseName,
  };

  // CLEANUP Database amd files
  await databaseDrop(databaseName, primaryConnection, options);

  // Let's clean up any prior tests as they may have failed and we around
  // the sql script so a developer can see what the issue was
  await dirRemove(cleanupFolder, { recursive: true, required: false });

  // We need to create a database to run our tests in.
  await databaseCreate(databaseName, primaryConnection);

  // TODO: This should all be configured
  const destinationBuildFolder = join('build');
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

  const destinationResetFolder = join('reset');
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

  const destinationTestFolder = join('test');
  await sqlFilesGenerate(
    databaseName,
    destinationTestFolder,
    DatabaseAccessMode.ReadWrite,
    DatabaseSystem.Postgresql,
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
        databaseName,
        destinationBuildFolder,
        newConnection,
        destinationRoot,
      );

      // run the tests
      await sqlFilesApply(
        databaseName,
        destinationTestFolder,
        newConnection,
        destinationRoot,
      );
      // tear down the entire thing
      await sqlFilesApply(
        databaseName,
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
        await databaseDrop(databaseName, primaryConnection, options);
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
