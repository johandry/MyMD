'use strict';

describe('Controller: MoviesCtrl', function () {

  // load the controller's module
  beforeEach(module('myMDApp'));

  var MoviesCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    MoviesCtrl = $controller('MoviesCtrl', {
      $scope: scope
    });
  }));

  // it('should attach a list of movies to the scope', function () {
  //   expect(scope.movies.length).not.toBe(0);
  // });
});
