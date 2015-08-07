'use strict';

define(['backbone'], function (Backbone) {
    return Backbone.Router.extend({
        routes: {
            '': 'index',
            foo: 'index'
        },
        index: function () { console.log(arguments);
            return require(['jsx!controllers/index']);
        },
        foo: function () { console.log(arguments);
            return require(['jsx!controllers/index']);
        }
    });
});