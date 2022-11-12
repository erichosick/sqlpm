import {
  join,
} from 'node:path';

import {
  MessagingOptions,
} from '@sqlpm/types-ts';

import {
  FilterOptions,
  NodePackage,
} from './types';
import { projectConfiguration } from './project-configuration';
import { nodePackageFromSource } from './node-package-from-source';
import { moduleLocations } from './module-locations';
import { loadNodePackage } from './load-node-package';

/**
 * Recursively build a dependency tree, loading sub-tree dependencies as needed.
 * @param pkg The current "root" package.
 * @param locations Array of paths: the locations where we will search for a
 * package.
 * @returns The "root" node package along with all resolved dependencies.
 */
const buildDependencyTree = async (
  pkg: NodePackage,
  locations: string[],
): Promise<NodePackage> => {
  if (pkg.package.dependencies) {
    for (const nodePackage of pkg.package.dependencies) {
      if (!nodePackage.source) {
        for (const location of locations) {
          const finalLocation = location.match(/node_module/) ? join(location, nodePackage.package.name) : location;
          // required false is there because a node package with sql in it will be
          // in a workspaces directory with the platform name in the path. But
          // projects that aren't sql centric may also show up. But we can't tell
          // if they are sql centric until we can open the package and see if
          // currentNode.package.database exists.
          // eslint-disable-next-line no-await-in-loop
          const localPackage = await loadNodePackage(join(finalLocation, 'package.json'), { required: false });

          if (localPackage?.content.name === nodePackage.package.name) {
            const packageDetail = nodePackageFromSource(localPackage);
            nodePackage.source = packageDetail.source;
            nodePackage.package.dependencies = packageDetail.package.dependencies;
            nodePackage.package.database = packageDetail.package.database;
            break;
          }
        }
      }
    }

    for (const childPackage of pkg.package.dependencies) {
      if (childPackage.package.dependencies) {
        if (childPackage.package.dependencies.length > 0) {
          // eslint-disable-next-line no-await-in-loop
          await buildDependencyTree(childPackage, locations);
        } // else {} nothing to build
      } // else {} nothing to build
    }
  }

  return pkg;
};

/**
 * Builds a node package dependency tree starting at the child path.
 * * **@param childPath** - The starting path of the dependency tree.
 * * **@param [options]** - See **{@link FilterOptions}**,
 *   **{@link MessagingOptions}**
 * * **@throws** - Errors if the `childPath` can not be resolved.
 * * **@returns** A node package dependency tree starting at the `childPath`
 * provided.
 *
 * **@example**
 * Get package dependency of the current directory
 * ```typescript
 * import {
 *   buildDependency
 * } from '@sqlpm/node-package-ts';
 *
 * const nodePackage = await buildDependency(__dirname);
 * expect(nodePackage?.source?.fileName).toEqual('package.json');
 * ```
*/
export const buildDependency = async (
  childPath: string,
  options?: FilterOptions & MessagingOptions,
): Promise<NodePackage | undefined> => {
  // Find all the package files starting at the child root and working our way
  // up the directory structure. We do this to find any workspace packages.
  const packages = await projectConfiguration(childPath);

  if (packages.length !== 0) {
    // Let's find all of the potential locations where sql files could be:
    // including ones in the lerna mono repo we are working in. We will use
    // these locations later to build out our final sql
    const locations = await moduleLocations(packages);
    const rootPackage = nodePackageFromSource(packages[0], options);
    const finalPackage = await buildDependencyTree(rootPackage, locations);
    return finalPackage;
  }

  throw Error(`Unable to build package dependencies because a 'package.json' file was not found at '${childPath}'.`);
};
