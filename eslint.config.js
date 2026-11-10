// https://docs.expo.dev/guides/using-eslint/
const expoConfig = require('eslint-config-expo/flat');

module.exports = [
  ...expoConfig,
  {
    // Protótipo estático guardado só como referência de design — não é código do app.
    ignores: ['node_modules/**', 'dist/**', '.expo/**', 'docs/**'],
  },
];
