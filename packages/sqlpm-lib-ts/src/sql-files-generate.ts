import {
  join,
} from 'node:path';

import {
  DatabaseSystem,
  DatabaseAccessMode,
  MessagingOptions,
  RunActionDirectory,
} from '@sqlpm/types-ts';

import {
  dirCreate, fileWrite,
} from '@sqlpm/file-async-ts';

import {
  sqlFindScript,
} from './sql-find-script';

import {
  SqlToRun,
} from './types';

import {
  sqlBuildScript,
} from './sql-build-script';

/**
 * Converts a semantic version into something that could be used in a file name.
 * Replaces . with -
 */
export const packageFileNameVersion = (
  semanticVersion: string,
): string => semanticVersion.replace(/\./g, '-');

export const packageNameToSchemaName = (
  packageName: string,
): string => packageName.replace(/-/g, '_');

/**
 * Given a bunch of sql script (located in memory), creates files using
 * a specific naming convention and saves the sql in these files.
 * @param databaseName - The name of the postgresql database the sql files
 * will run on.
 * @param destinationFolder The final location where all the sql script will
 * be placed.
 * @param DatabaseAccessMode
 * @param databaseSystem
 * @param runDirectories
 * @param options
 * @param childPath
 */
export const sqlFilesGenerate = async (
  databaseName: string,
  destinationFolder: string,
  databaseAccessMode: DatabaseAccessMode | string,
  databaseSystem: DatabaseSystem,
  runDirectories: RunActionDirectory[],
  options?: MessagingOptions,
  childPath?: string,
) => {
  const finalPath = join(childPath || __dirname, databaseName);
  let inverse = false;

  if (runDirectories.includes(RunActionDirectory.Reset)) {
    if (runDirectories.length > 1) {
      throw Error('The runDirectories option can only contain 1 run directory when RunActionDirectory.Reset is present.');
    } else {
      inverse = true;
    }
  }

  const sqlLocations: SqlToRun[] = await sqlFindScript(
    databaseAccessMode,
    databaseSystem,
    runDirectories,
    options,
    finalPath,
  );

  const scripts = await sqlBuildScript(sqlLocations);

  // const scripts = await sqlFilesGenerateScript(scriptLocations);
  // // applySqlToDatabase(scripts)
  const generatedDir = join(finalPath, destinationFolder);
  await dirCreate(generatedDir);

  let fileNumber: number = 0;

  const fileWritePromises = [];

  const finalScripts = inverse ? scripts.reverse() : scripts;

  for (const script of finalScripts) {
    const packageName = script.name.replace('/', '-');
    const packageVersion = packageFileNameVersion(script.version);

    // Let's increment the file numbers by 10 just in case someone wants to
    // programmatically/manually add some files after they have been generated
    fileNumber += 10;
    const fileNumberStr = fileNumber.toString().padStart(5, '0');

    const fileName = `${fileNumberStr}_${script.runAction}_${packageName}_v${packageVersion}.sql`;
    const fullPath = join(generatedDir, fileName);
    fileWritePromises.push(
      fileWrite(
        fullPath,
        script.script,
      ),
    );
  }

  await Promise.all(fileWritePromises);
};
