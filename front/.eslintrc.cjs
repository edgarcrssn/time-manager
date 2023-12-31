module.exports = {
  root: true,
  env: {
    browser: true,
    commonjs: true,
    es2020: true,
    node: true,
  },
  parser: 'vue-eslint-parser',
  parserOptions: {
    parser: '@typescript-eslint/parser',
    ecmaVersion: 2020,
  },
  extends: ['eslint:recommended', 'standard', 'plugin:@typescript-eslint/recommended', 'plugin:vue/recommended'],
  plugins: ['import', 'node', 'promise', 'standard', '@typescript-eslint', 'vue'],
  rules: {
    'vue/multi-word-component-names': 'off',
    'vue/no-use-v-if-with-v-for': 'off',
    '@typescript-eslint/no-explicit-any': 'warn',
    'vue/max-attributes-per-line': 'off',
    camelcase: 'off',
  },
}
