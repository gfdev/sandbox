require('expose?L!leaflet');

//require('angular');
require('angular-route');
require('angular-resource');
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
    .service('HH', function($q) {
        this.search = function () {

            
            //if (this.projects) return $q.when(this.projects);
            //
            //return fbAuth().then(function(auth) {
            //    var deferred = $q.defer();
            //    var ref = fbRef.child('projects-fresh/' + auth.auth.uid);
            //    var $projects = $firebase(ref);
            //    ref.on('value', function(snapshot) {
            //        if (snapshot.val() === null) {
            //            $projects.$set(window.projectsArray);
            //        }
            //        self.projects = $projects.$asArray();
            //        deferred.resolve(self.projects);
            //    });
            //
            //    //Remove projects list when no longer needed.
            //    ref.onDisconnect().remove();
            //    return deferred.promise;
            //});
        };
    })
    .controller('MapController', [ '$scope', function($scope) {

    }]);
