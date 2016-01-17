require('expose?L!leaflet');
require('angular');
require('angular-leaflet-directive');

require('bootstrap/dist/css/bootstrap.css');
require('leaflet/dist/leaflet.css');

angular.module('app', [ 'leaflet-directive' ])
    .controller('MapController', [ '$scope', function($scope) {

    }]);
