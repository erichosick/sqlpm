module.exports = {
  env: {
    es2021: true,
    node: true,
    'jest/globals': true, // - fix expect undefined no-undef
  },
  extends: [
    'airbnb-base',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  plugins: [
    '@typescript-eslint',
    'jest', // fix - expect undefined no-undef
  ],
  rules: {
    // For typescript, eslint errors when defining a function type. We need to
    // disable no-unused-vars and then enable typescripts no-unused-vars.
    // We can now define function types but also get warnings/errors on actual
    // unused vars.
    'no-unused-vars': 'off',
    '@typescript-eslint/no-unused-vars': 'warn',
    'import/extensions': [
      'error',
      {
        js: 'never',
        jsx: 'never',
        ts: 'never', // fix - Missing file extension "ts" for "../src"
        tsx: 'never',
      },
    ],

    'max-len': ['warn', { code: 100, ignoreUrls: true }],
    // https://stackoverflow.com/questions/69905008/stuck-with-eslint-error-separately-loops-should-be-avoided-in-favor-of-array-it
    // https://medium.com/@paul.beynon/thanks-for-taking-the-time-to-write-the-article-i-enjoyed-it-db916026647
    'no-restricted-syntax': 'off',

    // Enable files that have no default export.
    'import/prefer-default-export': 'off',

    // '{file}' is already declared in the upper scope...
    // see https://stackoverflow.com/questions/63961803/eslint-says-all-enums-in-typescript-app-are-already-declared-in-the-upper-scope
    'no-shadow': 'off',
    '@typescript-eslint/no-shadow': ['error'],

  },
  settings: {
    // fix -  Unable to resolve path to module '../src'
    'import/resolver': {
      node: {
        extensions: ['.ts'],
      },
    },
  },
};
