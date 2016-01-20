require('expose?L!leaflet');

require('angular');
require('angular-route');
require('angular-leaflet-directive');

require('bootstrap/dist/css/bootstrap.css');
require('leaflet/dist/leaflet.css');

angular.module('app', [ 'ngRoute', 'leaflet-directive' ])
    .value('apiURL', 'https://api.hh.ru/')
    .config(function($routeProvider) {
        $routeProvider
            .when('/map', {
                controller: 'Ctrl',
                template: require('map.html'),
                resolve: {
                    dictionary: [ 'srvDictionary', function(srvDictionary) {
                        return srvDictionary.get();
                    }]
                }
            })
            .otherwise({
                redirectTo: '/map'
            });
    })
    .service('srvHeadHunter', [ '$http','$q', 'apiURL', function($http, $q, apiURL) {
        this.fetch = function(endpoint, params) {
            var dfd = $q.defer();

            $http.get(apiURL + endpoint, {
                params: angular.extend({}, params)
            }).then(response => {
                if (response.status == 200) {
                    dfd.resolve(response.data);
                } else {
                    dfd.reject('Error retrieving data!');
                }
            });

            return dfd.promise;
        }
    }])
    .factory('srvDictionary', [ 'srvHeadHunter', function(HH) {
        var store;

        return {
            get: function() {
                if (store) return store;

                return HH.fetch('dictionaries').then(function(data) {
                    store = data;

                    return data;
                });
            }
        };
    }])
    .factory('srvSearch', ['srvHeadHunter', function(HH) {
        var defaults = {
            per_page: 100,
            enable_snippets: true,
            label: 'with_address',
            clusters: false,
            isMap: true
        };

        return {
            get: function(query, area) {
                return HH.fetch('vacancies', angular.extend(defaults, query, area));
            }
        };
    }])
    .controller('Ctrl', [ '$scope', 'srvSearch', 'leafletData', 'dictionary',
        function($scope, srvSearch, leafletData, dictionary) {
            angular.extend($scope, {
                minsk: {
                    lat: 53.90150637113244,
                    lng: 27.547874450683594,
                    zoom: 11
                }
            });

            $scope.dict = dictionary;

            $scope.search = function() {
                leafletData.getMap().then(map => {
                    var bounds = map.getBounds();

                    srvSearch.get($scope.query, _convertBoundsToParams(bounds)).then(data => {
                        if (angular.isArray(data.items))
                            $scope.markers = data.items.map(val => {
                                return {
                                    message: val.name,
                                    lat: val.address.lat,
                                    lng: val.address.lng
                                }
                            }).filter(val => val.lat !== null && val.lng !== null);
                    });
                });
            };

            function _convertBoundsToParams(bounds) {
                return {
                    bottom_lat: bounds.getSouth(),
                    left_lng: bounds.getWest(),
                    top_lat: bounds.getNorth(),
                    right_lng: bounds.getEast()
                }
            }
        }
    ]);
