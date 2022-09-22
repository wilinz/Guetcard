module.exports = {
    parserOptions: {
        ecmaVersion: 2021,
        sourceType: 'module',
    },
    root: true,
    env: {
        es6: true,
        node: true,
    },
    extends: [
        'eslint:recommended',
        'google',
    ],
    rules: {
        'quotes': ['warn', 'single'],
        'indent': ['warn', 4, { 'SwitchCase': 1 }],
        'linebreak-style': ['error', 'unix'],
        'semi': ['error', 'always'],
        'object-curly-spacing': ['warn', 'always'],
        'no-unused-vars': ['warn'],
    },
};
