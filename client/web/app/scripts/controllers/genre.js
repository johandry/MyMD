'use strict';

/**
 * @ngdoc function
 * @name myMDApp.controller:GenreShowCtrl
 * @description
 * # GenreShowCtrl
 * Controller of the myMDApp
 */
angular.module('myMDApp')
  .controller('GenreShowCtrl', function ($scope, $routeParams, Ref, $firebaseObject, $firebaseArray, $timeout) {
    var id = $routeParams.id;

    $scope.genre = $firebaseObject(Ref.child('genres/'+id));
    var movies = $firebaseArray(Ref.child('movies'));

    $scope.genre.$loaded()
      .then(function () {
        movies.$loaded()
          .then(function(){
            var genresMovies = [];

            for (var i = 0; i < movies.length; i++) {
              if (movies[i].genres.indexOf($scope.genre.name) > -1 || movies[i].mainGenre === $scope.genre.name) {
                genresMovies.push( movies[i] );
              }
            }
            $timeout(function() {
              $scope.movies = genresMovies;
            });
          })
          .catch(alert);
      })
      .catch(alert);

    function alert(msg) {
      $scope.err = msg;
      $timeout(function() {
        $scope.err = null;
      }, 5000);
    }
  });
