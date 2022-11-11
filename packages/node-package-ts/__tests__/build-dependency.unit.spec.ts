import {
  sep as separator,
} from 'node:path';

import {
  buildDependency,
} from '../src/index';

// import {
//   buildDependencyTree,
// } from '../src/build-dependency';

describe('build', () => {
  describe('buildDependency', () => {
    it('should successfully build a dependency', async () => {
      const nodePackage = await buildDependency(__dirname);
      const source = nodePackage?.source;
      expect(source?.absolutePath).toContain('sqlpm/packages/node-package-ts');
      expect(source?.fileName).toEqual('package.json');
      expect(nodePackage?.package.name).toEqual('@sqlpm/node-package-ts');
      expect(nodePackage?.package.version).toBeDefined();

      // NOTE: This may change if the package changes in some way.
      expect(nodePackage?.package.dependencies?.length).toEqual(6);

      expect(nodePackage?.package.dependencies).toBeDefined();

      // checking if recursion is working
      if (undefined !== nodePackage?.package.dependencies) {
        let found = false;
        for (const dependency of nodePackage.package.dependencies) {
          if (dependency.package.name === 'glob-promise') {
            if (
              dependency.package.dependencies
              && dependency.package.dependencies?.length > 0
            ) {
              found = true;
            }
          }
        }
        expect(found).toEqual(true);
      }
    });

    it('should return undefined if no valid directory name is provided', async () => {
      await expect(buildDependency(separator))
        .rejects
        .toThrow(`Unable to build package dependencies because a 'package.json' file was not found at '${separator}'.`);
    });
  });
});
