const path = require('path');

// TODO Need to modify this to better differentiate between dev and prod envs
module.exports = () => ({
  mode: 'production',
  devtool: 'inline-source-map', // TODO not in prod please
  module: {
    rules: [
      {
        test: /\.(js)$/,
        exclude: /node_modules|dist/,
        loader: 'babel-loader'
      }
    ]
  },
  resolve: {
    modules: [
      path.resolve(__dirname, 'src/'),
      path.resolve(__dirname, 'node_modules/')
    ],
    extensions: ['.js']
  },
  output: {
    path: path.resolve(__dirname, 'dist/'),
    publicPath: '/dist/',
    filename: '[name].js'
  },
  target: 'node',
  entry: {
    update: './src/update.js',
    handler: './src/handler.js'
  },
  externals: {
    awsSdk: 'aws-sdk'
  }
});
