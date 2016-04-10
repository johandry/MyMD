'use strict';

/**
 * @ngdoc function
 * @name myMDApp.controller:MovieShowCtrl
 * @description
 * # MovieShowCtrl
 * Controller of the myMDApp
 */
angular.module('myMDApp')
  .controller('MovieShowCtrl', function ($scope, $routeParams, Ref, $firebaseObject) {
    var id = $routeParams.id;

    $scope.movie = $firebaseObject(Ref.child('movies/'+id));

    $scope.movie.$loaded()
      .then(function(movie){
        movie.artwork = encodeURI(movie.artwork);
      })
      .catch(alert);

    function alert(msg) {
      $scope.err = msg;
      $timeout(function() {
        $scope.err = null;
      }, 5000);
    }
  });
