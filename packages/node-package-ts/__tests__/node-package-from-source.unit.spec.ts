import {
  NodePackage,
  NodePackageContentSource,
  nodePackageFromSource,
} from '../src/index';

describe('nodePackageFromSource', () => {
  describe('no dependencies', () => {
    it(`should return a single {@link NodePackage} with
      no dependencies`, () => {
      const source: NodePackageContentSource = {
        sourcePath: '/some/package.json',
        content: {
          name: '@sqlpm/types',
          version: '^0.0.0',
        },
      };

      const nodePackage: NodePackage = nodePackageFromSource(source);
      expect(nodePackage).toEqual({
        source: { absolutePath: '/some', fileName: 'package.json' },
        package: { name: '@sqlpm/types', version: '^0.0.0', dependencies: [] },
      });
    });

    // TODO: Should we error out if an empty sourcePath is provided?
    it(`should return a single {@link NodePackage} with
      no dependencies and empty sourcePath`, () => {
      const source: NodePackageContentSource = {
        sourcePath: '',
        content: {
          name: '@sqlpm/types',
          version: '^0.0.0',
        },
      };

      const nodePackage: NodePackage = nodePackageFromSource(source);
      expect(nodePackage).toEqual({
        source: { absolutePath: '.', fileName: '' },
        package: { name: '@sqlpm/types', version: '^0.0.0', dependencies: [] },
      });
    });
  });

  describe('dependencies', () => {
    it(`should return a single {@link NodePackage} with
      dependencies`, () => {
      const source: NodePackageContentSource = {
        sourcePath: '/some/package.json',
        content: {
          name: '@sqlpm/types',
          version: '^0.0.0',
          dependencies: {
            '@sqlpm/types': '^0.0.0',
          },
        },
      };

      const nodePackage: NodePackage = nodePackageFromSource(source);
      expect(nodePackage).toEqual({
        source: { absolutePath: '/some', fileName: 'package.json' },
        package: {
          name: '@sqlpm/types',
          version: '^0.0.0',
          dependencies: [
            {
              package: { name: '@sqlpm/types', version: '^0.0.0', dependencies: [] },
            },
          ],
        },
      });
    });

    it(`should return a single {@link NodePackage} with
      dependencies and filter`, () => {
      const source: NodePackageContentSource = {
        sourcePath: '/some/package.json',
        content: {
          name: '@sqlpm/types',
          version: '^0.0.0',
          dependencies: {
            '@sqlpm/types': '^0.0.0',
          },
        },
      };

      const nodePackage: NodePackage = nodePackageFromSource(
        source,
        { exclude: /^@sqlpm\/[\S]/ },
      );
      expect(nodePackage).toEqual({
        source: { absolutePath: '/some', fileName: 'package.json' },
        package: {
          name: '@sqlpm/types',
          version: '^0.0.0',
          dependencies: [],
        },
      });
    });
  });
});
