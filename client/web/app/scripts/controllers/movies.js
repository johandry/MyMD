'use strict';

/**
 * @ngdoc function
 * @name myMDApp.controller:MoviesCtrl
 * @description
 * # MoviesCtrl
 * Controller of the myMDApp
 */
angular.module('myMDApp')
  .controller('MoviesCtrl', function ($scope, Ref, $firebaseArray, $timeout) {
    $scope.movies = $firebaseArray(Ref.child('movies'));

    $scope.movies.$loaded().catch(alert);

    function alert(msg) {
      $scope.err = msg;
      $timeout(function() {
        $scope.err = null;
      }, 5000);
    }
  });
