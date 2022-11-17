import {
  DatabasePlatform, DatabasePurpose, RunActionDirectory,
} from '@sqlpm/types-ts';

import {
  projectDirectories,
} from '../src/index';

describe('projectDirectories', () => {
  it(`should generate a default project directory
    given a schema and database purpose`, () => {
    const directories = projectDirectories(
      'persona',
      DatabasePlatform.Postgresql,
    );
    expect(directories).toEqual(
      [
        'schemas/persona/postgresql/readwrite/prerun',
        'schemas/persona/postgresql/readwrite/run',
        'schemas/persona/postgresql/readwrite/postrun',
        'schemas/persona/postgresql/readwrite/seed',
        'schemas/persona/postgresql/readwrite/test',
        'schemas/persona/postgresql/readwrite/reset',
      ],
    );
  });

  it('should generate a subset of folders', () => {
    const directories = projectDirectories(
      'persona',
      DatabasePlatform.Postgresql,
      [DatabasePurpose.Readonly, DatabasePurpose.Readwrite],
      [RunActionDirectory.Run, RunActionDirectory.Seed],
    );

    expect(directories).toEqual(
      [
        'schemas/persona/postgresql/readonly/run',
        'schemas/persona/postgresql/readonly/seed',
        'schemas/persona/postgresql/readwrite/run',
        'schemas/persona/postgresql/readwrite/seed',
      ],
    );
  });
});
