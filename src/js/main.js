require.config({
    baseUrl: 'js',
    paths: {
        jquery: 'libs/jquery',
        underscore: 'libs/underscore',
        backbone: 'libs/backbone',
        react: 'libs/react',
        JSXTransformer: 'libs/JSXTransformer',
        jsx: 'libs/jsx',
        text: 'libs/text'
    },
    shim: {
        backbone: {
            deps: [
                'jquery',
                'underscore'
            ],
            exports: 'Backbone'
        },
        jquery: {
          exports: '$'
        },
        underscore: {
            exports: '_'
        }
    }
});

require(['backbone', 'app'], function(Backbone, Router) {
    new Router();
    
    Backbone.history.start(/*{ pushState: true }*/);
});