'use strict';

describe('Controller: GenresCtrl', function () {

  // load the controller's module
  beforeEach(module('myMDApp'));

  var GenresCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    GenresCtrl = $controller('GenresCtrl', {
      $scope: scope
    });
  }));

});
