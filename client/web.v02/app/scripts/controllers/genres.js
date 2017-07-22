'use strict';

/**
 * @ngdoc function
 * @name myMDApp.controller:GenresCtrl
 * @description
 * # GenresCtrl
 * Controller of the myMDApp
 */
angular.module('myMDApp')
  .controller('GenresCtrl', function ($scope, Ref, $firebaseArray, $timeout) {
    $scope.genres = $firebaseArray(Ref.child('genres'));

    $scope.genres.$loaded().catch(alert);

    function alert(msg) {
      $scope.err = msg;
      $timeout(function() {
        $scope.err = null;
      }, 5000);
    }
  });
