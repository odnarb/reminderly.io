// jest.config.js (CommonJS)

module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  injectGlobals: true,     // so expect/describe/it/jest are globals
  testMatch: [
    '**/*.test.ts',
    '**/*.spec.ts',
  ],
};
