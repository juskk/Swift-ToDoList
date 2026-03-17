module.exports = {
  presets: ['module:@react-native/babel-preset'],
  plugins: [
    ['module:react-native-dotenv', {
      moduleName: '@env',
      path: '.env',
      safe: true,         // require all vars listed in .env.example to be present
      allowUndefined: false,
    }],
  ],
};
