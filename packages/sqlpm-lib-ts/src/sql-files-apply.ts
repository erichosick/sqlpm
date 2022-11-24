import {
  join,
  parse,
} from 'node:path';

import {
  dirRead,
} from '@sqlpm/file-async-ts';

import {
  sqlApplyFromFile,
  connectionOpen,
  Connection,
} from '@sqlpm/postgresql-client-ts';

// TODO: Pass the sql client that we will use to this.

export const sqlFilesApply = async (
  databaseName: string,
  sourceFolder: string,
  connection: Connection,
  sourceRoot?: string,
) => {
  const finalRoot = join(sourceRoot || __dirname, databaseName);
  const absoluteSource = join(
    finalRoot,
    sourceFolder,
  );

  const filesUnfiltered = await dirRead(absoluteSource);

  const sql = connectionOpen(connection);

  try {
    // await Promise.all(applyPromises);

    if (filesUnfiltered !== undefined) {
    // TODO: Testing
      const sqlFiles = filesUnfiltered
        .filter((path) => parse(path).ext === '.sql')
        .sort();

      for (const sqlFile of sqlFiles) {
        const absoluteSqlFile = join(absoluteSource, sqlFile);
        // NOTE: Had logic that generated an array of promises then did
        // await Promise.all(applyPromises); but it looks like they start the
        // task immediately. So, there is no known execution order.
        // https://stackoverflow.com/questions/30823653
        // See https://bigcodenerd.org/resolving-promises-sequentially-javascript/
        // generators section. This may be an option.

        // eslint-disable-next-line no-await-in-loop
        await sqlApplyFromFile(absoluteSqlFile, sql);
      }
    } // else {} nothing to do
  } finally {
    await sql.end({ timeout: 1 });
  }
};
