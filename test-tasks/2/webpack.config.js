var pkg = require('./package.json')
    , webpack = require('webpack')
    , HtmlWebpackPlugin = require('html-webpack-plugin')
    , ExtractTextPlugin = require("extract-text-webpack-plugin")
    , autoprefixer = require('autoprefixer')
    , src = __dirname + '/src'
    , NODE_ENV = process.env.NODE_ENV || 'development'
;

module.exports = {
    context: src,
    devtool: NODE_ENV === 'development' ? 'cheap-source-map' : null,
    watch:  NODE_ENV === 'development',
    entry: {
        app: './app',
        vendor: './vendor'
    },
    output: NODE_ENV === 'development'
        ? { path: __dirname + '/build', filename: '[name].js', publickPath: '/' }
        : { path: __dirname + '/dist', filename: '[name].[hash].js' },
    resolve: {
        root: src,
        extensions: [ '', '.js', '.jsx' ],
        modulesDirectories: [ 'node_modules' ]
    },
    module: {
        //preLoaders: [
        //    { test: /\.jsx?$/, include: src, loader: 'eslint' }
        //],
        loaders: [
            { test: /\.jsx$/, include: src, loader: 'react-hot!babel?cacheDirectory' },
            { test: /\.s?css$/i, loader: ExtractTextPlugin.extract('style', 'css!sass!postcss') },
            { test: /\.(?:jpe?g|png|gif|svg|eot|ttf|woff\d?|otf)$/, loader: 'url?limit=1&name=[name].[ext]?[hash]' } // + 1024 * 1024 * 10 }
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
        new webpack.optimize.OccurenceOrderPlugin(),
        new webpack.DefinePlugin({
            NODE_ENV: JSON.stringify(NODE_ENV)
        }),
        new webpack.ProvidePlugin({
            React: 'react',
            ReactDOM: 'react-dom'
        }),
        new webpack.optimize.CommonsChunkPlugin({
            name: [ 'vendor' ],
            filename: '[name]' + (NODE_ENV === 'development' ? '' : '.[hash]') + '.js'
        }),
        new HtmlWebpackPlugin({
            name: pkg.name,
            title: pkg.description,
            template: 'index.tmpl',
            inject: 'body'
        }),
        new ExtractTextPlugin('[name]' + (NODE_ENV === 'development' ? '' : '.[contenthash]') + '.css', { allChunks: true })
    ].concat(NODE_ENV !== 'development'
        ? new webpack.optimize.UglifyJsPlugin({ compress: { warnings: false, disable: NODE_ENV === 'development' }})
        : []
    )
};
