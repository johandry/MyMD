'use strict';

/**
 * @ngdoc function
 * @name myMDApp.controller:ArtistsCtrl
 * @description
 * # ArtistsCtrl
 * Controller of the myMDApp
 */
angular.module('myMDApp')
  .controller('ArtistsCtrl', function ($scope, Ref, $firebaseArray, $timeout) {
    $scope.artists = $firebaseArray(Ref.child('artists'));

    $scope.artists.$loaded().catch(alert);

    function alert(msg) {
      $scope.err = msg;
      $timeout(function() {
        $scope.err = null;
      }, 5000);
    }
  });
