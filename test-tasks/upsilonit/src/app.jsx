require('expose?L!leaflet');
require('angular');
require('angular-leaflet-directive');

require('bootstrap/dist/css/bootstrap.css');
require('leaflet/dist/leaflet.css');

var app = angular.module('app', [ 'leaflet-directive' ]);

app.controller('MapController', [ '$scope', function($scope) {

}]);
