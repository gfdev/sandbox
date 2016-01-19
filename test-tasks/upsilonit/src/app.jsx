require('expose?L!leaflet');

require('angular');
require('angular-route');
//require('angular-resource');
require('angular-leaflet-directive');

require('bootstrap/dist/css/bootstrap.css');
require('leaflet/dist/leaflet.css');

angular.module('app', [ 'ngRoute', 'leaflet-directive' ])
    .config(function($routeProvider, $httpProvider) {
        $httpProvider.defaults.useXDomain = true;

        delete $httpProvider.defaults.headers.common['X-Requested-With'];
        //$httpProvider.interceptors.push('redirectInterceptor');

        var resolveVacancies = {
            vacancies: function (HH) {
                return HH.search();
            }
        };

        $routeProvider
            .when('/', {
                controller: 'MapController as projectList',
                template: require('./map.html'),
                resolve: resolveVacancies
            })
            .otherwise({
                redirectTo: '/'
            });
    })
    .service('HH', ['$http','$q', function($http, $q) {
        this.search = function() {
            var deferred = $q.defer();

            $http.get('http://hh.ru/shards/searchvacancymap?top_right_lat=54.02979493800219&items_on_page=100&bottom_left_lat=53.698611658494&top_right_lng=28.616075614310958&label=with_address&text=javascript&enable_snippets=true&salary=&bottom_left_lng=26.308946708060958&clusters=true&isMap=true&_=1448885030019').then(function(response) {
                if (response.status == 200) {
                    deferred.resolve(response.data);
                } else {
                    deferred.reject('Error retrieving user info');
                }
            });

            return deferred.promise;
        }
    }])
    .controller('MapController', [ '$scope', function($scope) {

    }]);
