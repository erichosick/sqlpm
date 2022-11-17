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
  description: string,
  purposes: DatabasePurpose[] = [DatabasePurpose.Readwrite],
  actions: RunActionDirectory[] = runActionDirectoryAsArray(),
  workspace: string = 'schemas',
) => {
  const directories: string[] = [];
  for (const purpose of purposes) {
    for (const action of actions) {
      const dir = join(
        workspace,
        packageName,
        platform,
        purpose,
        action,
      );
      directories.push(dir);
    }
  }

  return directories;
};

export const projectPackageTemplate = (
  packageName: string,
  platform: DatabasePlatform,
  description: string,
): string => `{
  "name": "@sqlpm/${packageName}-${platform}",
  "version": "0.0.0",
  "description": "${description}",
  "keywords": [
    "sqlpm",
    "sql-watch",
    "database schema",
    "postgresql"
  ],
  "author": "Eric Hosick <erichosick@gmail.com>",
  "homepage": "https://github.com/erichosick/sqlpm/tree/main/packages/schemas/${packageName}-${platform}",
  "bugs": {
    "url": "https://github.com/erichosick/sqlpm/issues",
    "email": "erichosick@gmail.com"
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

): string => `# **${packageName}-${platform}**

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

export const licenseTemplate = (): string => `MIT License

Copyright (c) 2022 Eric Hosick

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
  purposes: DatabasePurpose[] = [DatabasePurpose.Readwrite],
  actions: RunActionDirectory[] = runActionDirectoryAsArray(),
  workspace: string = 'schemas',
) => {
  const directories = projectDirectories(
    packageName,
    platform,
    description,
    purposes,
    actions,
    workspace,
  );

  await dirsCreate(
    process.cwd(),
    directories,
  );

  const packageDir = join(process.cwd(), workspace, packageName);

  await fileWrite(
    join(packageDir, 'README.md'),
    readmeTemplate(packageName, platform),
  );

  await fileWrite(
    join(packageDir, 'LICENSE.md'),
    licenseTemplate(),
  );

  await fileWrite(
    join(packageDir, 'package.json'),
    projectPackageTemplate(packageName, platform, description),
  );

  const sqlFilePromises = [];

  for (const purpose of purposes) {
    for (const action of actions) {
      const file = join(
        packageDir,
        platform,
        purpose,
        action,
        `100_${action}.sql`,
      );

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
