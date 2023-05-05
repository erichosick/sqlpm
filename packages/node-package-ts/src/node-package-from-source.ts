import {
  basename,
  dirname,
} from 'node:path';

import {
  FilterOptions, NodePackage, NodePackageContentSource, NodePackages,
} from './types';

import {
  filterDependencies,
} from './filter-dependencies';
import { nodePackagesFromDependency } from './node-package-from-dependency';

/**
 * Converts a loaded node package into an easy-to-manipulate data object.
 * During conversion, dependencies can be filtered.
 * **@param contentSource {@link NodePackageContentSource }** Contains
 * the source (file name) and package.json content.
 *
 * **@returns A {@link NodePackage} with, optionally, filtered dependencies.
 *
 * **@example**
 *
 * ```typescript
 * import {
 *   NodePackage,
 *   NodePackageContentSource,
 *   nodePackageFromSource,
 * } from '@sqlpm/node-package-ts'
 *
 * const source: NodePackageContentSource = {
 *   sourcePath: '/some/package.json',
 *   content: {
 *     name: '@sqlpm/types',
 *     version: '^0.0.0',
 *     dependencies: {
 *       '@sqlpm/types': '^0.0.0',
 *     },
 *   },
 * };
 *
 * const nodePackage: NodePackage = nodePackageFromSource(
 *   source,
 *   { exclude: /^@sqlpm\/[\S]/ },
 * );
 * expect(nodePackage).toEqual({
 *   source: {
 *     absolutePath: '/some',
 *     fileName: 'package.json'
 *   },
 *   package: {
 *     name: '@sqlpm/types',
 *     version: '^0.0.0',
 *     dependencies: [],
 *   },
 * });
 * ```
 */
export const nodePackageFromSource = (
  contentSource: NodePackageContentSource,
  options?: FilterOptions,
): NodePackage => {
  const { content } = contentSource;

  let dependentNodePackages: NodePackages = nodePackagesFromDependency(
    content.dependencies,
  );

  dependentNodePackages = filterDependencies(
    dependentNodePackages,
    options,
  );

  const result: NodePackage = {
    source: {
      absolutePath: dirname(contentSource.sourcePath),
      fileName: basename(contentSource.sourcePath),
    },
    package: {
      name: content.name,
      version: content.version,
      dependencies: dependentNodePackages,
      // add a database property if one exists
      ...(content.sqlpm && { sqlpm: content.sqlpm }),
    },
  };
  return result;
};
