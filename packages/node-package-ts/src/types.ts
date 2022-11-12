import {
  JSONSchemaForNPMPackageJsonFiles,
} from '@schemastore/package';
import { ContentSource } from '@sqlpm/file-async-ts';
import { MessagingOptions } from '@sqlpm/types-ts';

/**
 * Represents an object whose key is the source of some content, and value is
 * the content itself. For example, the source may be a package.json file.
 * They key is the package.json absolute path and the value becomes the
 * content of the json file.
 */
export interface ContentSourceObject<ContentType> {
  [key: string]: ContentType
}

/**
 * Supported database platforms. The name of the database platform is also
 * the name of the directory for that platform. For postgresql sql script would
 * be in a directory {project_root}/schemas/postgresql/*
 *
 * **@remarks**
 * We intend to add 'sqlite' | 'mssql' | 'mysql' | 'mariadb' | 'snowflake'.
 *
 * **@remarks**
 * When adding a new DatabasePlatform, be sure to updated the root
 * package.json to include the new database platform schema directory.
 *
 * **@example**
 * Adding postgresql packages required the following update to `package.json`.
 * ```json
 * {
 *   // ...
 *   "workspaces": [
 *     "schemas/postgresql/*",
 *   ],
 * }
 * ```
 */
export type DatabasePlatform = 'postgresql';

/**
  * Provides information about the database schemas defined in a module such
  * as the database platform the sql script is written for.
  *
  * **@remarks**
  * Intend to add other attributes like schemaName and domainsCovered
  * (business domains like person, invoice, etc.)
  *
  * **@interface**
  * **@member {@link DatabaseInformation.platform}**
  */
export interface DatabaseInformation {

  /**
   * The database platform(s) of all sql scripts for a given package are
   * written for. In cases where the database platforms are compatible,
   * one of the {@link DatabasePlatform}s will be chosen to represent all
   * compatible database platforms.
   */
  // eslint-disable-next-line no-use-before-define
  platform: DatabasePlatform | DatabasePlatforms
}

/**
 * An array of {@link DatabasePlatform}.
 */
export type DatabasePlatforms = DatabasePlatform[];

/**
 * Extends the {@link JSONSchemaForNPMPackageJsonFiles} type.
 *
 * **@type**
 * * **@member {@link PkgJSONSchemaExt.name}** - name is now required
 * * **@member {@link PkgJSONSchemaExt.version}** - version is now required
 * * **@member {@link PkgJSONSchemaExt.database}** - Addition of property
 *
 * **@example**
 * Update to `package.json` file.
 *
 * ```json
 * {
 *   // ...
 *   "database": {
 *     "platform": 'postgresql'
 *   }
 * }
 * ```
 */
export type PkgJSONSchemaExt = JSONSchemaForNPMPackageJsonFiles & {
  /**
   * The name of the package. Now required as opposed to optional.
   */
  name: string;

  /**
   * Version must be parsable by node-semver, which is bundled with
   * npm as a dependency. Now required as opposed to optional.
   */
  version: string;

  /**
   * Information about the database used within the package.
   * See {@link DatabaseInformation}.
   */
  database?: DatabaseInformation;
};

/**
 * A {@link ContentSource} generic resolved using {@link PkgJSONSchemaExt}.
 */
export type NodePackageContentSource = ContentSource<PkgJSONSchemaExt>;

/**
 * An array of {@link NodePackageContentSource}.
 */
export type NodePackageContentSources = NodePackageContentSource[];

// -----------------------------------------------------------------------------

/**
 * Contains information about where content came from including path and name.
 *
 * **@interface**
 * * **@member {@link NodePackageSource.path}**
 * * **@member {@link NodePackageSource.fileName}**
 *
 */
export interface NodePackageSource {
  /**
   * The absolute path to a file.
   */
  absolutePath: string;

  /**
   * The file name within the absolutePath.
   *
   * **@example**
   * The file name `package.json`.
   */
  fileName: string;
}

/**
 * Contains minimal meta-data about a `package.json` file.
 *
 * **@interface**
 * * **@member {@link NodePackageMetadata.name}**
 * * **@member {@link NodePackageMetadata.version}**
 * * **@member {@link NodePackageMetadata.dependencies}**
 * * **@member {@link NodePackageMetadata.database}**
 *
*/
export interface NodePackageMetadata {
  /**
   * The name of the package: pulled from the name property in package.json.
  */
  name: string;

  /**
   * The version of the package: pulled from the version property
   * in package.json.
   */
  version: string;

  /**
   * List of all dependencies of the package parsed from the dependencies
   * property in package.json. See {@link NodePackages}.
   */
  // eslint-disable-next-line no-use-before-define
  dependencies?: NodePackages;

  /**
   * Database information {@link DatabaseInformation}
   */
  database?: DatabaseInformation

}

/**
 * A hierarchial data structure that contains information a subset of
 * information contained in a package.jon.
 *
 * **@interface**
 * * **@member {@link NodePackage.source}**
 * * **@member {@link NodePackage.package}**
 */
export interface NodePackage {

  /**
   * The source of the content when it is known. See {@link NodePackageSource}.
   */
  source?: NodePackageSource | undefined,

  /**
   * Node Package meta-data. See {@link NodePackageMetadata}
   */
  package: NodePackageMetadata

}

/**
 * An array of {@link NodePackage}.
 */
export type NodePackages = NodePackage[];

/**
 * Options for function {@link filterDependencies}
 * @interface
 * * **@members {@link FilterOptions.include}**
 * * **@members {@link FilterOptions.exclude}**
 */
export interface FilterOptions extends MessagingOptions {

  /**
   * When provided, returns any node package dependencies that match the
   * regular expression.
   */
  include?: RegExp | RegExp[];

  /**
   * When provided, filters any node package dependencies that match the
   * regular expression.
   */
  exclude?: RegExp | RegExp[];
}
