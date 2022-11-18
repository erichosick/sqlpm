import {
  join,
} from 'node:path';

import {
  dirsCreate,
  fileWrite,
} from '@sqlpm/file-async-ts';

import {
  DatabasePurpose,
  RunActionDirectory,
  DatabasePlatform,
  runActionDirectoryAsArray,
} from '@sqlpm/types-ts';

/**
 * Given a workspace and database platform, returns the directory where
 * schema packages are created (for that database platform).
 * * **@param workspace** - Workspace name.
 * * **@param platform** - Database platform name
 * * **@returns** - The directory where schema packages are created
 * (for that database platform).
 *
 * **@example**
 *
 * Returns a directory for Postgresql.
 *
 * ```typescript
 * expect(
 *   platformDirectory(
 *     'schemas',
 *      DatabasePlatform.Postgresql,
 *   ),
 * ).toEqual('schemas/postgresql');
 * ```
 */
export const platformDirectory = (
  workspace: string,
  platform: DatabasePlatform,
): string => join(workspace, platform);

/**
 * Given a platform directory and package name, returns the
 * directory where the sql package resides.
 * * **@param platDir** - The directory created by calling
 * {@link platformDirectory}.
 * * **@param packageName** - The name of the json package. Most likely also
 * the database schema name.
 * * **@returns** - The directory where the sql package resides.
 *
 * **@example**
 *
 * Returns a directory where the universal package resides. universal is also
 * the name of the database schema.
 *
 * ```typescript
 * expect(
 *   packageDirectory(
 *     'schemas',
 *      DatabasePlatform.Postgresql,
 *     'universal',
 *   ),
 * ).toEqual('schemas/postgresql/universal');
 * ```
 */
export const packageDirectory = (
  platDir: string,
  packageName: string,
): string => join(platDir, packageName);

/**
 * Given a package directory and purpose, returns the
 * directory where sql script is placed for the given purpose.
 * **@example**
 * For example, if the purpose of the database is that it is used as a readonly
 * database, then all sql script for the read only database will be placed in
 * this directory.
 *
 * * **@param pkgDir** - The directory created by calling
 * {@link packageDirectory}
 * * **@param purpose** - The purpose of the database.
 * **@example**
 * A readonly database.
 * * **@returns** - The directory where sql script is placed for the given
 * purpose.
 *
 * **@example**
 *
 * Returns the directory where sql script is placed for a readwrite database.
 *
 * ```typescript
 * expect(
 *   purposeDirectory(
 *     'schemas',
 *      DatabasePlatform.Postgresql,
 *     'universal',
 *      DatabasePurpose.Readwrite,
 *   ),
 * ).toEqual('schemas/postgresql/universal/readwrite');
 * ```
 */
export const purposeDirectory = (
  pkgDir: string,
  purpose: DatabasePurpose,
): string => join(pkgDir, purpose);

/**
 * Given a workspace, database platform, package name, purpose and action,
 * returns the directory where sql script for a specific action are placed.
 * **@example**
 * The directory where all test sql script are placed.
 *
 * * **@param purposeDir** - The directory created by calling
 * {@link purposeDirectory}
 * * **@param action** - The action taken with the SQL script such as test
 * **@example**
 * Scripts in a test action directory will run when the action of 'test' is
 * ran.
 * * **@returns** - The directory where sql script is placed for the given
 * action.
 *
 * **@example**
 *
 * Returns the directory where sql script is placed for the given action.
 *
 * ```typescript
 * expect(
 *   actionDirectory(
 *     'schemas',
 *      DatabasePlatform.Postgresql,
 *     'universal',
 *      DatabasePurpose.Readwrite,
 *      RunActionDirectory.Test,
 *   ),
 * ).toEqual('schemas/postgresql/universal/readwrite/test');
 * ```
 */
export const actionDirectory = (
  purposeDir: string,
  action: RunActionDirectory,
): string => join(purposeDir, action);

/**
 * Generates a list of directories that would be used as part of the
 * projects directories.
 * * **@param packageName** - The name of the folder that contains the sqlpm
 * package.
 * * **@param platform** - The database platform this package supports.
 * * **@param description** - A description of the package used in the
 * package.json file and the description of the database schema.
 * * **@param purposes** - One or more database purposes. A directory will be
 * generated for each purpose. See {@link DatabasePurpose}.
 * * **@param actions ** - One or more sqlpm action directories: each one with a
 * specific meaning. See {@link RunActionDirectory}
 * * **@param workspace** - The workspace where all sqlpm projects are located.
 * By default this is `schemas` and it is recommended to use this directory.
 *
 * **@remark**
 * Adding a different workspace is ok, but remember to update this libraries
 *
 *
 * @returns An array of directories that would be part of the sqlpm project.
 */
export const projectDirectories = (
  packageName: string,
  platform: DatabasePlatform,
  purposes: DatabasePurpose[] = [DatabasePurpose.Readwrite],
  actions: RunActionDirectory[] = runActionDirectoryAsArray(),
  workspace: string = 'schemas',
) => {
  const directories: string[] = [];
  for (const purpose of purposes) {
    for (const action of actions) {
      const platDir = platformDirectory(workspace, platform);
      const pkgDir = packageDirectory(platDir, packageName);
      const purposeDir = purposeDirectory(pkgDir, purpose);
      const actDir = actionDirectory(purposeDir, action);
      directories.push(actDir);
    }
  }

  return directories;
};

export const projectPackageTemplate = (
  packageName: string,
  platform: DatabasePlatform,
  description: string,
  author: string,
  email: string,
): string => `{
  "name": "@sqlpm/${packageName}-${platform}",
  "version": "0.0.0",
  "description": "${description}",
  "keywords": [
    "sqlpm",
    "database schema",
    "postgresql"
  ],
  "author": "${author} <${email}>",
  "homepage": "https://github.com/erichosick/sqlpm/tree/main/packages/schemas/${packageName}-${platform}",
  "bugs": {
    "url": "https://github.com/erichosick/sqlpm/issues",
    "email": "${email}"
  },
  "license": "MIT",
  "publishConfig": {
    "registry": "https://registry.npmjs.org/",
    "access": "public"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/erichosick/sqlpm.git"
  },
  "database": {
    "platform": "${platform}"
  }
}
`;

export const readmeTemplate = (
  packageName: string,
  platform: DatabasePlatform,
  description: string,
): string => `# **${packageName}-${platform}**

${description}

## Usage
`;

export const sqlTemplate = (
  packageName: string,
  action: string,
): string => `
-- -----------------------------------------------------------------------------
-- ${packageName} - ${action}
-- 
-- -----------------------------------------------------------------------------

`;

export const sqlTemplateRun = (
  packageName: string,
  action: string,
  description: string,
): string => `
-- -----------------------------------------------------------------------------
-- ${packageName} - ${action}
-- 
-- -----------------------------------------------------------------------------

-- SCHEMA ----------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS ${packageName};
COMMENT ON SCHEMA ${packageName} IS '${description}';

`;

export const licenseTemplate = (author: string): string => `# MIT License

Copyright (c) 2022 ${author}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.`;

export const schemaProjectInit = async (
  packageName: string,
  platform: DatabasePlatform,
  description: string,
  author: string,
  email: string,
  purposes: DatabasePurpose[] = [DatabasePurpose.Readwrite],
  actions: RunActionDirectory[] = runActionDirectoryAsArray(),
  workspace: string = 'schemas',
) => {
  const directories = projectDirectories(
    packageName,
    platform,
    purposes,
    actions,
    workspace,
  );

  await dirsCreate(
    process.cwd(),
    directories,
  );

  const platformDir = platformDirectory(workspace, platform);
  const packageDir = packageDirectory(platformDir, packageName);

  const absolutePackageDir = join(process.cwd(), packageDir);

  await fileWrite(
    join(absolutePackageDir, 'README.md'),
    readmeTemplate(packageName, platform, description),
  );

  await fileWrite(
    join(absolutePackageDir, 'LICENSE.md'),
    licenseTemplate(author),
  );

  await fileWrite(
    join(absolutePackageDir, 'package.json'),
    projectPackageTemplate(packageName, platform, description, author, email),
  );

  const sqlFilePromises = [];

  for (const purpose of purposes) {
    const purposeDir = purposeDirectory(packageDir, purpose);
    for (const action of actions) {
      const actionDir = actionDirectory(purposeDir, action);
      const file = join(actionDir, `100_${action}.sql`);

      if (action === RunActionDirectory.Run) {
        sqlFilePromises.push(
          fileWrite(
            file,
            sqlTemplateRun(packageName, action, description),
          ),
        );
      } else {
        sqlFilePromises.push(

          fileWrite(
            file,
            sqlTemplate(packageName, action),
          ),
        );
      }
    }
  }
  await Promise.all(sqlFilePromises);
};