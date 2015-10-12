'use strict';


// Declare app level module which depends on filters, and services
angular.module('myMoviesDashboardApp', [
  'ngRoute',
  'myMoviesDashboardApp.filters',
  'myMoviesDashboardApp.services',
  'myMoviesDashboardApp.directives',
  'myMoviesDashboardApp.controllers',
  'ui.bootstrap'
]).
config(['$routeProvider', function($routeProvider) {
  $routeProvider.when('/movies', {templateUrl: 'partials/movie_list.html', controller: 'MovieListCtrl'});
  $routeProvider.when('/movies/:id', {templateUrl: 'partials/movie_show.html', controller: 'MovieShowCtrl'});
  $routeProvider.when('/view2', {templateUrl: 'partials/partial2.html', controller: 'MyCtrl2'});
  $routeProvider.otherwise({redirectTo: '/movies'});
}]);
