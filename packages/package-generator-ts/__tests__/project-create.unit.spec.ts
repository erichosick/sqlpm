import {
  DatabaseSystem,
  DatabaseAccessMode,
  RunActionDirectory,
} from '@sqlpm/types-ts';

import {
  actionDirectory,
  packageDirectory,
  databaseSystemDirectory,
  purposeDirectory,
} from '../src/index';

describe('schemaProjectInit', () => {
  it('should create the correct directories', () => {
    const databaseSystemDir = databaseSystemDirectory(
      'schemas',
      DatabaseSystem.Postgresql,
    );
    expect(databaseSystemDir).toEqual('schemas/postgresql');

    const packageDir = packageDirectory(databaseSystemDir, 'universal');
    expect(packageDir).toEqual('schemas/postgresql/universal');

    const purposeDir = purposeDirectory(
      packageDir,
      DatabaseAccessMode.ReadWrite,
    );
    expect(purposeDir).toEqual('schemas/postgresql/universal/readwrite');

    const actionDir = actionDirectory(purposeDir, RunActionDirectory.Test);
    expect(actionDir).toEqual('schemas/postgresql/universal/readwrite/test');
  });
});
