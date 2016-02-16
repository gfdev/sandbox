var pkg = require('./package.json')
    , webpack = require('webpack')
    , HtmlWebpackPlugin = require('html-webpack-plugin')
    , autoprefixer = require('autoprefixer')
    , src = __dirname + '/src'
    , NODE_ENV = process.env.NODE_ENV || 'development'
;

module.exports = {
    context: src,
    devtool: NODE_ENV === 'development' ? 'cheap-source-map' : null,
    entry: './app',
    resolve: {
        root: src,
        extensions: [ '', '.js', '.jsx', '.html' ],
        modulesDirectories: [ 'node_modules' ]
    },
    module: {
        preLoaders: [
            { test: /\.jsx?$/, include: src, loader: 'eslint' }
        ],
        loaders: [
            { test: require.resolve('angular'), loader: 'exports?window.angular' },
            { test: /angular[^\/]+\.js$/i, loader: 'imports?angular' },
            { test: /\.jsx$/, include: src, loader: 'babel?cacheDirectory' },
            { test: /\.html$/, include: src, loader: 'html' },
            { test: /\.css$/i, loader: 'style!css!postcss' },
            { test: /\.(?:jpe?g|png|gif|svg|eot|ttf|woff\d?|otf)$/, loader: 'url?limit=' + 1024 * 1024 * 10 }
        ]
    },
    postcss: [
        autoprefixer({ browsers: [ 'last 2 versions' ] })
    ],
    devServer: {
        host: '0.0.0.0',
        port: 3000
    },
    plugins: [
        new webpack.NoErrorsPlugin(),
        new webpack.optimize.DedupePlugin(),
        new webpack.DefinePlugin({
            NODE_ENV: JSON.stringify(NODE_ENV)
        }),
        new webpack.ProvidePlugin({
            angular: 'angular'
        }),
        new HtmlWebpackPlugin({
            name: pkg.name,
            title: pkg.description,
            template: 'index.tmpl',
            inject: 'head'
        })
    ].concat(NODE_ENV !== 'development' ? [
        new webpack.optimize.UglifyJsPlugin({
            compress: {
                warnings: false
            }
        })
    ] : [])
};

module.exports.output = NODE_ENV === 'development' ?
    {
        path: __dirname + '/build',
        filename: pkg.name + '.js'
    } : {
        path: __dirname + '/dist',
        filename: '[hash].js'
    };
