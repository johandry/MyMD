'use strict';

/* Controllers */

angular.module('myMoviesDashboardApp.controllers', [])
  .controller('MovieListCtrl', ['$scope', '$http', function($scope, $http) {
  	$http.get('movies/movies.json').success(function(data){
  		$scope.movies = data;
  	});

    $http.get('movies/artists.json').success(function(data){
      $scope.artists = data;
    });

    $http.get('movies/genres.json').success(function(data){
      $scope.genres = data;
    });

	  $scope.order = 'id';

  }])
  .controller('MovieShowCtrl', ['$scope', '$http', '$routeParams', function($scope, $http, $routeParams) {
  	$scope.id = $routeParams.id;
  	$http.get('movies/movies.json').success(function(data){
  		// The first movie has ID = 1 and the json array starts with ID = 0 so need to subtract 1 to the id
  		$scope.movie = data[parseInt($scope.id) - 1];
  	});  	
  }])
  .controller('MyCtrl2', ['$scope', function($scope) {

  }]);
