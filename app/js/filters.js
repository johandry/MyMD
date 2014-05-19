'use strict';

/* Filters */

angular.module('myMoviesDashboardApp.filters', []).
  filter('checkmark', function() {
    return function (text) {
      return text ? '\u2713' : '\u2718';
    };
  }).
  filter('interpolate', ['version', function(version) {
    return function(text) {
      return String(text).replace(/\%VERSION\%/mg, version);
    };
  }]);
