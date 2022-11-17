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
  readFileString,
} from '@sqlpm/file-async-ts';

import {
  schemaProjectInit,
  sqlTemplateRun,
  sqlTemplate,
  readmeTemplate,
  projectPackageTemplate,
  licenseTemplate,
} from '../src/index';

describe('schemaProjectInit', () => {
  it(`should create a complete project
    while not using defaults`, async () => {
    // NOTE: Changing the workspace name here is only for testing and
    // not recommended to do in production.
    const workspaceName = 'test-workspace01';
    const packageName = 'test-project';
    const description = 'A test package.';
    const author = 'The Author';
    const email = 'author@email.com';
    await schemaProjectInit(
      packageName,
      DatabasePlatform.Postgresql,
      description,
      author,
      email,
      [DatabasePurpose.Readwrite],
      [
        RunActionDirectory.Run,
        RunActionDirectory.Reset,
        RunActionDirectory.Test,
      ],
      workspaceName,
    );

    const projectDir = join(
      process.cwd(),
      workspaceName,
      packageName,
    );

    const purposeDir = join(
      projectDir,
      'postgresql',
      'readwrite',
    );

    expect(await (readFileString(
      join(projectDir, 'README.md'),
    ))).toEqual(
      readmeTemplate(
        packageName,
        DatabasePlatform.Postgresql,
        description,
      ),
    );

    expect(await (readFileString(
      join(projectDir, 'package.json'),
    ))).toEqual(
      projectPackageTemplate(
        packageName,
        DatabasePlatform.Postgresql,
        description,
        author,
        email,
      ),
    );

    expect(await (readFileString(
      join(projectDir, 'LICENSE.md'),
    ))).toEqual(
      licenseTemplate(author),
    );

    expect(await (readFileString(
      join(purposeDir, 'run', '100_run.sql'),
    ))).toEqual(sqlTemplateRun(packageName, 'run', description));

    expect(await (readFileString(
      join(purposeDir, 'test', '100_test.sql'),
    ))).toEqual(sqlTemplate(packageName, 'test'));

    expect(await (readFileString(
      join(purposeDir, 'reset', '100_reset.sql'),
    ))).toEqual(sqlTemplate(packageName, 'reset'));

    await dirRemove(
      join(process.cwd(), workspaceName),
      {
        recursive: true,
      },
    );
  });

  it(`should create a complete project
    while using defaults`, async () => {
    // NOTE: Changing the workspace name here is only for testing and
    // not recommended to do in production.
    const packageName = 'test-project2';
    const description = 'A test package.';
    const workspaceName = 'schemas';
    const author = 'The Author';
    const email = 'author@email.com';
    await schemaProjectInit(
      packageName,
      DatabasePlatform.Postgresql,
      description,
      author,
      email,
    );

    const projectDir = join(
      process.cwd(),
      workspaceName,
      packageName,
    );

    const purposeDir = join(
      projectDir,
      'postgresql',
      'readwrite',
    );

    expect(await (readFileString(
      join(purposeDir, 'prerun', '100_prerun.sql'),
    ))).toEqual(sqlTemplate(packageName, 'prerun'));

    expect(await (readFileString(
      join(purposeDir, 'postrun', '100_postrun.sql'),
    ))).toEqual(sqlTemplate(packageName, 'postrun'));

    expect(await (readFileString(
      join(purposeDir, 'reset', '100_reset.sql'),
    ))).toEqual(sqlTemplate(packageName, 'reset'));

    await dirRemove(
      join(process.cwd(), workspaceName, packageName),
      {
        recursive: true,
      },
    );
  });
});
