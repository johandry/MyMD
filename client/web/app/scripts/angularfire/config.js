angular.module('firebase.config', [])
  .constant('FBURL', 'https://mymoviesdb.firebaseio.com')
  .constant('SIMPLE_LOGIN_PROVIDERS', ['password','anonymous','google'])

  .constant('loginRedirectPath', '/login');
