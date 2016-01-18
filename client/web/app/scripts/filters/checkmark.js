'use strict';

angular.module('myMDApp')
  .filter('checkmark', function() {
    return function (text) {
      return text ? '\u2713' : '\u2718';
    };
  });
