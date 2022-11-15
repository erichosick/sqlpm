import {
  join,
} from 'node:path';

import {
  readDirectory,
} from '../src/index';

describe('readDirectory', () => {
  it('should read a directory', async () => {
    const files: string[] | undefined = await readDirectory(__dirname);
    expect(files?.length).toBeGreaterThan(0);
  });

  it(`should NOT error if the directory is not found and
  required = false`, async () => {
    const dir = join(__dirname, 'does_not_exist');
    const content: string[] | undefined = await readDirectory(dir, { required: false });
    expect(content).toBeUndefined();
  });

  it(`should error if a directory is not found and the
  required option is true`, async () => {
    const dir = join(__dirname, 'does_not_exist');
    await expect(readDirectory(dir))
      .rejects
      .toThrow(/^ENOENT: no such file or directory, scandir '[\S]*__tests__\/does_not_exist'$/);
  });
});
