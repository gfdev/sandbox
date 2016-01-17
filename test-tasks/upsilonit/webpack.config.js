var pkg = require('./package.json')
    , webpack = require('webpack')
    , HtmlWebpackPlugin = require('html-webpack-plugin')
    , src = __dirname + '/src'
;

module.exports = {
    context: src,
    entry: '../index.js',
    output: {
        path: __dirname + '/dist',
        filename: '[hash].js'
    },
    module: {
        preLoaders: [
            { test: /\.jsx?$/, include: src, loader: 'eslint' }
        ],
        loaders: [
            { test: require.resolve("angular"), loader: "expose?angular" },
            { test: require.resolve("angular-leaflet-directive"), loader: "imports?angular" },
            { test: /\.jsx$/, include: src, loader: 'babel?cacheDirectory' },
            { test: /\.s?css$/i, loader: 'style!css!autoprefixer!sass' },
            { test: /\.(?:jpe?g|png|gif|svg|eot|ttf|woff\d?|otf)$/, loader: 'url?limit=' + 1024 * 1024 * 10 }
        ]
    },
    plugins: [
        new webpack.optimize.UglifyJsPlugin({
            compress: {
                warnings: false
            }
        }),
        new webpack.NoErrorsPlugin(),
        new webpack.optimize.DedupePlugin(),
        new webpack.optimize.OccurenceOrderPlugin(true),
        new HtmlWebpackPlugin({
            title: pkg.name,
            name: pkg.name,
            template: 'src/index.html',
            inject: 'head'
        })
    ]
};
