require('expose?L!leaflet');

require('angular');
require('angular-route');
require('angular-leaflet-directive');

require('bootstrap/dist/css/bootstrap.css');
require('leaflet/dist/leaflet.css');

angular.module('app', [ 'ngRoute', 'leaflet-directive' ])
    .config(function($routeProvider) {
        $routeProvider
            .when('/', {
                controller: 'MapController as projectList',
                template: require('./map.html')
            })
            .otherwise({
                redirectTo: '/'
            });
    })
    .controller('MapController', [ '$scope', function($scope) {

    }]);
