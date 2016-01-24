require('expose?L!leaflet');
require('script!leaflet.markercluster');

require('angular');
require('angular-route');
require('angular-leaflet-directive');

require('bootstrap/dist/css/bootstrap.css');
require('leaflet/dist/leaflet.css');
require('leaflet.markercluster/dist/MarkerCluster.css');
require('leaflet.markercluster/dist/MarkerCluster.Default.css');

angular.module('app', [ 'ngRoute', 'leaflet-directive' ])
    .value('apiURL', 'https://api.hh.ru/')
    .config([ '$routeProvider', function($routeProvider) {
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
    }])
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
    .factory('srvDictionary', [ 'srvHeadHunter', function(srvHeadHunter) {
        var store;

        return {
            get: function() {
                if (store) return store;

                return srvHeadHunter.fetch('dictionaries').then(data => {
                    store = data;

                    return data;
                });
            }
        };
    }])
    .factory('srvSearch', [ 'srvHeadHunter', function(srvHeadHunter) {
        var defaults = {
            per_page: 100,
            enable_snippets: false,
            label: 'with_address',
            clusters: false,
            isMap: true
        };

        return {
            get: function(query, area) {
                var params = angular.extend(defaults, query, area);

                if (query.salary) params.only_with_salary = true;

                return srvHeadHunter.fetch('vacancies', params);
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
                },
                layers: {
                    baselayers: {
                        osm: {
                            name: 'OpenStreetMap',
                            type: 'xyz',
                            url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
                        }
                    },
                    overlays: {
                        vacancies: {
                            name: 'Vacancies',
                            type: 'markercluster',
                            visible: true
                        }
                    }
                }
            });

            $scope.dict = dictionary;

            $scope.$on('leafletDirectiveMap.moveend', function() {
                $scope.search();
            });

            $scope.search = function() {
                if (!$scope.query) return;

                $scope.submited = true;

                leafletData.getMap().then(map => {
                    var bounds = map.getBounds();

                    srvSearch.get($scope.query, _convertBoundsToParams(bounds)).then(data => {
                        if (angular.isArray(data.items))
                            $scope.markers = data.items.map(val => {
                                return {
                                    message: val.name,
                                    layer: 'vacancies',
                                    lat: val.address.lat,
                                    lng: val.address.lng
                                }
                            }).filter(val => val.lat !== null && val.lng !== null);

                        $scope.submited = false;
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
