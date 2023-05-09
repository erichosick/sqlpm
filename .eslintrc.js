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
    // In cases where we want to include dev dependencies in test code
    'import/no-extraneous-dependencies': [
      'off', { devDependencies: ['**/*.test.js', '**/*.spec.js'] },
    ],
    // In cases where the number of lines becomes > max-len. We should be able
    // to format the code as needed.
    'arrow-body-style': 'off',
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
        json: 'always',
      },
    ],

    'max-len': [
      'warn', {
        code: 80,
        ignoreUrls: true,
        ignoreTemplateLiterals: true,
        ignoreRegExpLiterals: true,
        ignoreStrings: true,
      },
    ],
    // https://stackoverflow.com/questions/69905008
    'no-restricted-syntax': 'off',

    // Enable files that have no default export.
    'import/prefer-default-export': 'off',

    // '{file}' is already declared in the upper scope...
    // see https://stackoverflow.com/questions/63961803
    'no-shadow': 'off',
    '@typescript-eslint/no-shadow': ['error'],

    // see https://github.com/mattphillips/jest-expect-message
    'jest/valid-expect': [
      'error',
      {
        maxArgs: 2,
      },
    ],
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
