import {
  join,
  dirname,
} from 'node:path';

import {
  loadNodePackage,
  NodePackageContentSource,
} from '../src/index';

describe('loadNodePackage', () => {
  describe('loading a valid package', () => {
    it(`should find at least the two package.json files
      for this project`, async () => {
      const dir = join(dirname(__dirname), 'package.json');
      // eslint-disable-next-line max-len
      const projConfig: NodePackageContentSource | undefined = await loadNodePackage(dir);
      expect(projConfig).toBeDefined();

      expect(projConfig?.sourcePath)
        .toEqual(join(dirname(__dirname), 'package.json'));
      expect(projConfig?.content.name).toBeDefined();
      expect(projConfig?.content.version).toBeDefined();
    });

    it('should return undefined when the file is not required', async () => {
      // eslint-disable-next-line max-len
      const projConfig: NodePackageContentSource | undefined = await loadNodePackage(
        '',
        { required: false },
      );

      expect(projConfig).toBeUndefined();
    });
  });

  describe('error', () => {
    it('should throw an error when a package is missing the name', async () => {
      const dir = join(
        __dirname,
        'test-files',
        'node-package-no-name-or-version',
        'package.json',
      );

      await expect(loadNodePackage(dir))
        .rejects
        .toThrow(/^All node project files \(such as package.json\) that are within the scope of '[\S]*__tests__\/test-files\/node-package-no-name-or-version\/package.json' must have a name and version.$/);
    });

    it('should error when the path is an empty string', async () => {
      await expect(loadNodePackage(''))
        .rejects
        .toThrow(/ENOENT: no such file or directory, open ''/);
    });
  });
});
