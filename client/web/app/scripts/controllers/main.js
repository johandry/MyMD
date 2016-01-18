'use strict';

/**
 * @ngdoc function
 * @name myMDApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the myMDApp
 */
angular.module('myMDApp')
  .controller('MainCtrl', function ($scope) {
    $scope.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];
  });
