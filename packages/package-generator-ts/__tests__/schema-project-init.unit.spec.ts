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
  readFileString,
} from '@sqlpm/file-async-ts';

import {
  schemaProjectInit,
  sqlTemplateRun,
  sqlTemplate,
  readmeTemplate,
  projectPackageTemplate,
  licenseTemplate,
  packageDirectory,
  databaseSystemDirectory,
  purposeDirectory,
  actionDirectory,
  sqlTemplateReset,
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
      DatabaseSystem.Postgresql,
      description,
      author,
      email,
      [DatabaseAccessMode.ReadWrite],
      [
        RunActionDirectory.Run,
        RunActionDirectory.Reset,
        RunActionDirectory.Test,
      ],
      workspaceName,
    );

    const platDir = databaseSystemDirectory(
      workspaceName,
      DatabaseSystem.Postgresql,
    );

    const packageDir = packageDirectory(platDir, packageName);
    const absolutePackageDir = join(process.cwd(), packageDir);
    const purposeDir = purposeDirectory(packageDir, DatabaseAccessMode.ReadWrite);
    const absolutePurposeDir = join(process.cwd(), purposeDir);

    expect(await (readFileString(
      join(absolutePackageDir, 'README.md'),
    ))).toEqual(
      readmeTemplate(
        packageName,
        DatabaseSystem.Postgresql,
        description,
      ),
    );

    expect(await (readFileString(
      join(absolutePackageDir, 'package.json'),
    ))).toEqual(
      projectPackageTemplate(
        packageName,
        DatabaseSystem.Postgresql,
        description,
        author,
        email,
      ),
    );

    expect(await (readFileString(
      join(absolutePackageDir, 'LICENSE.md'),
    ))).toEqual(
      licenseTemplate(author),
    );

    const runActionDir = actionDirectory(
      absolutePurposeDir,
      RunActionDirectory.Run,
    );

    expect(await (readFileString(
      join(runActionDir, '100_create_resources.sql'),
    ))).toEqual(sqlTemplateRun(packageName, 'run', description, author));

    const testActionDir = actionDirectory(
      absolutePurposeDir,
      RunActionDirectory.Test,
    );

    expect(await (readFileString(
      join(testActionDir, '100_test.sql'),
    ))).toEqual(sqlTemplate(packageName, 'test', author));

    const resetActionDir = actionDirectory(
      absolutePurposeDir,
      RunActionDirectory.Reset,
    );

    expect(await (readFileString(
      join(resetActionDir, '100_reset.sql'),
    ))).toEqual(sqlTemplateReset(packageName, 'reset', author));

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
    const databaseSystem = 'test-system';
    await schemaProjectInit(
      packageName,
      databaseSystem as DatabaseSystem.Postgresql,
      description,
      author,
      email,
    );

    const platDir = databaseSystemDirectory(
      workspaceName,
      // Let's not accidentally delete one of our actual database platforms when
      // running tests
      databaseSystem as DatabaseSystem.Postgresql,
    );

    const packageDir = packageDirectory(platDir, packageName);
    const purposeDir = purposeDirectory(
      packageDir,
      DatabaseAccessMode.ReadWrite,
    );
    const absolutePurposeDir = join(process.cwd(), purposeDir);

    const prerunActionDir = actionDirectory(
      absolutePurposeDir,
      RunActionDirectory.Prerun,
    );

    expect(await (readFileString(
      join(prerunActionDir, '100_prerun.sql'),
    ))).toEqual(sqlTemplate(packageName, 'prerun', author));

    const postrunActionDir = actionDirectory(
      absolutePurposeDir,
      RunActionDirectory.Postrun,
    );

    expect(await (readFileString(
      join(postrunActionDir, '100_postrun.sql'),
    ))).toEqual(sqlTemplate(packageName, 'postrun', author));

    const resetActionDir = actionDirectory(
      absolutePurposeDir,
      RunActionDirectory.Reset,
    );

    expect(await (readFileString(
      join(resetActionDir, '100_reset.sql'),
    ))).toEqual(sqlTemplateReset(packageName, 'reset', author));

    await dirRemove(
      join(process.cwd(), platDir),
      {
        recursive: true,
      },
    );
  });
});
