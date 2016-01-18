'use strict';

/**
 * @ngdoc function
 * @name myMDApp.controller:ArtistShowCtrl
 * @description
 * # ArtistShowCtrl
 * Controller of the myMDApp
 */
angular.module('myMDApp')
  .controller('ArtistShowCtrl', function ($scope, $routeParams, Ref, $firebaseObject, $firebaseArray, $timeout) {
    var id = $routeParams.id;

    $scope.artist = $firebaseObject(Ref.child('artists/'+id));
    var movies = $firebaseArray(Ref.child('movies'));

    $scope.artist.$loaded()
      .then(function () {
        movies.$loaded()
          .then(function(){
            var artistsMovies = [];

            for (var i = 0; i < movies.length; i++) {
              if (movies[i].artist.indexOf($scope.artist.name) > -1) {
                artistsMovies.push( movies[i] );
              }
            }
            $timeout(function() {
              $scope.movies = artistsMovies;
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
