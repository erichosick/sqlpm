// import { Dependency } from '@schemastore/package';
import {
  NodePackage,
  NodePackages,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  PkgJSONSchemaExt,
} from '@sqlpm/node-package-ts';

import {
  MessagingOptions,
  DatabaseSystem,
} from '@sqlpm/types-ts';

/**
 * Given a root node package (see {@link NodePackage}), filters and only
 * returns packages that have a database property within the
 * package.json (see {@link PkgJSONSchemaExt})
 * The dependency order is inverted using a post order search. All lower nodes
 * are resolved then the next level up and finally the top level node.
 * This is the order that the sql scripts would then execute.
 *
 * * **@param rootPackage** -
 * * **@param databaseSystem** -
 * * **@param options** -  See {@link MessagingOptions}
 * * **@returns**
 */
export const sqlPackagesGetInverted = (
  rootPackage: NodePackage,
  databaseSystem: DatabaseSystem,
  options?: MessagingOptions,
): NodePackages => {
  const packages: NodePackages = [];

  function postOrder(currentNode: NodePackage): void {
    if (currentNode.package.dependencies) {
      for (const poPkg of currentNode.package.dependencies) {
        postOrder(poPkg);
      }
    } // else {} there are no dependencies for this NodePackage

    if (currentNode.package.sqlpm) {
      const systems = Array.isArray(currentNode.package.sqlpm.databaseSystem)
        ? currentNode.package.sqlpm.databaseSystem
        : [currentNode.package.sqlpm.databaseSystem];

      if (systems.includes(databaseSystem)) {
        packages.push(currentNode);
      }
    }
  }

  postOrder(rootPackage);
  return packages;
};
