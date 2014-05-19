'use strict';

/* Controllers */

angular.module('myMoviesDashboardApp.controllers', [])
  .controller('MovieListCtrl', ['$scope', '$http', function($scope, $http) {
  	$http.get('movies/movies.json').success(function(data){
  		$scope.movies = data;
  	});

	  $scope.order = 'id';

  }])
  .controller('MovieShowCtrl', ['$scope', '$http', '$routeParams', function($scope, $http, $routeParams) {
  	$scope.id = $routeParams.id;
  	$http.get('movies/movies.json').success(function(data){
  		// TODO: The first movie has ID = 2 instead of ID = 1. Replace the -2 below for -1 when fixed.
  		$scope.movie = data[parseInt($scope.id) - 2];
  	});  	
  }])
  .controller('MyCtrl2', ['$scope', function($scope) {

  }]);
