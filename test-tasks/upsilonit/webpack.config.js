var pkg = require('./package.json')
    , webpack = require('webpack')
    , HtmlWebpackPlugin = require('html-webpack-plugin')
    , src = __dirname + '/src'
    , NODE_ENV = process.env.NODE_ENV || 'development'
;

module.exports = {
    context: src,
    devtool: NODE_ENV === 'development' ? 'source-map' : null,
    entry: '../index.js',
    resolve: {
        root: src,
        extensions: [ '', '.js', '.jsx', '.html' ]
    },
    module: {
        preLoaders: [
            { test: /\.jsx?$/, include: src, loader: 'eslint' }
        ],
        loaders: [
            { test: require.resolve("angular"), loader: "expose?angular" },
            { test: /angular[\w.-]+\.js$/i, loader: "imports?angular" },
            { test: /\.jsx$/, include: src, loader: 'babel?cacheDirectory' },
            { test: /\.html$/, include: src, loader: 'html' },
            { test: /\.css$/i, loader: 'style!css!autoprefixer' },
            { test: /\.(?:jpe?g|png|gif|svg|eot|ttf|woff\d?|otf)$/, loader: 'url?limit=' + 1024 * 1024 * 10 }
        ]
    },
    plugins: [
        new webpack.NoErrorsPlugin(),
        new webpack.optimize.DedupePlugin(),
        new webpack.optimize.OccurenceOrderPlugin(),
        new webpack.DefinePlugin({
            NODE_ENV: JSON.stringify(NODE_ENV)
        }),
        new HtmlWebpackPlugin({
            name: pkg.name,
            title: pkg.description,
            template: 'src/index.html',
            inject: 'head'
        })
    ].concat(NODE_ENV !== 'development' ? [
        new webpack.optimize.UglifyJsPlugin({
            compress: {
                warnings: false
            }
        }),
    ] : []),
    devServer: {
        host: '0.0.0.0',
        port: 3000
    }
};

module.exports.output = NODE_ENV === 'development' ?
    {
        filename: pkg.name + '.js'
    } : {
        path: __dirname + '/dist',
        filename: '[hash].js'
    };
