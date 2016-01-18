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
  });
