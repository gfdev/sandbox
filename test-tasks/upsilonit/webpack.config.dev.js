var pkg = require('./package.json')
    , webpack = require('webpack')
    , HtmlWebpackPlugin = require('html-webpack-plugin')
    , src = __dirname + '/src'
;

module.exports = {
    context: src,
    devtool: 'eval',
    entry: '../index.js',
    devServer: {
        host: '0.0.0.0',
        port: 3000
    },
    output: {
        filename: pkg.name + '.js'
    },
    resolve: {
        root: src,
        extensions: [ '', '.js', '.jsx' ]
    },
    module: {
        preLoaders: [
            { test: /\.jsx?$/, include: src, loader: 'eslint' }
        ],
        loaders: [
            { test: require.resolve("angular"), loader: "expose?angular" },
            { test: require.resolve("angular-leaflet-directive"), loader: "imports?angular" },
            { test: /\.jsx$/, include: src, loader: 'babel?cacheDirectory' },
            { test: /\.css$/i, loader: 'style!css!autoprefixer' },
            { test: /\.(?:jpe?g|png|gif|svg|eot|ttf|woff\d?|otf)$/, loader: 'url?limit=' + 1024 * 1024 * 10 }
        ]
    },
    plugins: [
        new webpack.NoErrorsPlugin(),
        new webpack.optimize.DedupePlugin(),
        new webpack.optimize.OccurenceOrderPlugin(),
        new HtmlWebpackPlugin({
            title: pkg.name,
            name: pkg.name,
            template: 'src/index.html',
            inject: 'head'
        })
    ]
};
