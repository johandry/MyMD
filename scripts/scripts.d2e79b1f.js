"use strict";angular.module("myMDApp",["ngAnimate","ngCookies","ngMessages","ngResource","ngRoute","ngSanitize","ngTouch","firebase","firebase.ref","firebase.auth"]),angular.module("myMDApp").controller("MainCtrl",["$scope",function(a){a.awesomeThings=["HTML5 Boilerplate","AngularJS","Karma"]}]),angular.module("firebase.config",[]).constant("FBURL","https://mymoviesdb.firebaseio.com").constant("SIMPLE_LOGIN_PROVIDERS",["password","anonymous","google"]).constant("loginRedirectPath","/login"),angular.module("firebase.ref",["firebase","firebase.config"]).factory("Ref",["$window","FBURL",function(a,b){return new a.Firebase(b)}]),angular.module("myMDApp").controller("ChatCtrl",["$scope","Ref","$firebaseArray","$timeout",function(a,b,c,d){function e(b){a.err=b,d(function(){a.err=null},5e3)}a.messages=c(b.child("messages").limitToLast(10)),a.messages.$loaded()["catch"](e),a.addMessage=function(b){b&&a.messages.$add({text:b})["catch"](e)}}]),angular.module("myMDApp").filter("reverse",function(){return function(a){return angular.isArray(a)?a.slice().reverse():[]}}),angular.module("myMDApp").filter("checkmark",function(){return function(a){return a?"✓":"✘"}}),function(){angular.module("firebase.auth",["firebase","firebase.ref"]).factory("Auth",["$firebaseAuth","Ref",function(a,b){return a(b)}])}(),angular.module("myMDApp").controller("LoginCtrl",["$scope","Auth","$location","$q","Ref","$timeout",function(a,b,c,d,e,f){function g(a){return h(a.substr(0,a.indexOf("@"))||"")}function h(a){a+="";var b=a.charAt(0).toUpperCase();return b+a.substr(1)}function i(){c.path("/account")}function j(b){a.err=b}a.oauthLogin=function(c){a.err=null,b.$authWithOAuthPopup(c,{rememberMe:!0}).then(i,j)},a.anonymousLogin=function(){a.err=null,b.$authAnonymously({rememberMe:!0}).then(i,j)},a.passwordLogin=function(c,d){a.err=null,b.$authWithPassword({email:c,password:d},{rememberMe:!0}).then(i,j)},a.createAccount=function(c,h,k){function l(a){var b=e.child("users",a.uid),h=d.defer();return b.set({email:c,name:g(c)},function(a){f(function(){a?h.reject(a):h.resolve(b)})}),h.promise}a.err=null,h?h!==k?a.err="Passwords do not match":b.$createUser({email:c,password:h}).then(function(){return b.$authWithPassword({email:c,password:h},{rememberMe:!0})}).then(l).then(i,j):a.err="Please enter a password"}}]),angular.module("myMDApp").controller("AccountCtrl",["$scope","user","Auth","Ref","$firebaseObject","$timeout",function(a,b,c,d,e,f){function g(a){i(a,"danger")}function h(a){i(a,"success")}function i(b,c){var d={text:b+"",type:c};a.messages.unshift(d),f(function(){a.messages.splice(a.messages.indexOf(d),1)},1e4)}a.user=b,a.logout=function(){c.$unauth()},a.messages=[];var j=e(d.child("users/"+b.uid));j.$bindTo(a,"profile"),a.changePassword=function(b,d,e){a.err=null,b&&d?d!==e?g("Passwords do not match"):c.$changePassword({email:j.email,oldPassword:b,newPassword:d}).then(function(){h("Password changed")},g):g("Please enter all fields")},a.changeEmail=function(b,d){a.err=null,c.$changeEmail({password:b,newEmail:d,oldEmail:j.email}).then(function(){j.email=d,j.$save(),h("Email changed")})["catch"](g)}}]),angular.module("myMDApp").directive("ngShowAuth",["Auth","$timeout",function(a,b){return{restrict:"A",link:function(c,d){function e(){b(function(){d.toggleClass("ng-cloak",!a.$getAuth())},0)}d.addClass("ng-cloak"),a.$onAuth(e),e()}}}]),angular.module("myMDApp").directive("ngHideAuth",["Auth","$timeout",function(a,b){return{restrict:"A",link:function(c,d){function e(){b(function(){d.toggleClass("ng-cloak",!!a.$getAuth())},0)}d.addClass("ng-cloak"),a.$onAuth(e),e()}}}]),angular.module("myMDApp").config(["$routeProvider","SECURED_ROUTES",function(a,b){a.whenAuthenticated=function(c,d){return d.resolve=d.resolve||{},d.resolve.user=["Auth",function(a){return a.$requireAuth()}],a.when(c,d),b[c]=!0,a}}]).config(["$routeProvider",function(a){a.when("/",{templateUrl:"views/main.html",controller:"MainCtrl"}).when("/chat",{templateUrl:"views/chat.html",controller:"ChatCtrl"}).when("/login",{templateUrl:"views/login.html",controller:"LoginCtrl"}).whenAuthenticated("/account",{templateUrl:"views/account.html",controller:"AccountCtrl"}).when("/movies",{templateUrl:"views/movies.html",controller:"MoviesCtrl"}).when("/movies/:id",{templateUrl:"views/movie.html",controller:"MovieShowCtrl"}).when("/artists",{templateUrl:"views/artists.html",controller:"ArtistsCtrl"}).when("/artists/:id",{templateUrl:"views/artist.html",controller:"ArtistShowCtrl"}).when("/genres",{templateUrl:"views/genres.html",controller:"GenresCtrl"}).when("/genres/:id",{templateUrl:"views/genre.html",controller:"GenreShowCtrl"}).otherwise({redirectTo:"/"})}]).run(["$rootScope","$location","Auth","SECURED_ROUTES","loginRedirectPath",function(a,b,c,d,e){function f(a){!a&&g(b.path())&&b.path(e)}function g(a){return d.hasOwnProperty(a)}c.$onAuth(f),a.$on("$routeChangeError",function(a,c,d,f){"AUTH_REQUIRED"===f&&b.path(e)})}]).constant("SECURED_ROUTES",{}),angular.module("myMDApp").controller("MoviesCtrl",["$scope","Ref","$firebaseArray","$timeout",function(a,b,c,d){function e(b){a.err=b,d(function(){a.err=null},5e3)}a.movies=c(b.child("movies")),a.movies.$loaded()["catch"](e)}]),angular.module("myMDApp").controller("ArtistsCtrl",["$scope","Ref","$firebaseArray","$timeout",function(a,b,c,d){function e(b){a.err=b,d(function(){a.err=null},5e3)}a.artists=c(b.child("artists")),a.artists.$loaded()["catch"](e)}]),angular.module("myMDApp").controller("MovieShowCtrl",["$scope","$routeParams","Ref","$firebaseObject",function(a,b,c,d){var e=b.id;a.movie=d(c.child("movies/"+e))}]),angular.module("myMDApp").controller("ArtistShowCtrl",["$scope","$routeParams","Ref","$firebaseObject","$firebaseArray","$timeout",function(a,b,c,d,e,f){function g(b){a.err=b,f(function(){a.err=null},5e3)}var h=b.id;a.artist=d(c.child("artists/"+h));var i=e(c.child("movies"));a.artist.$loaded().then(function(){i.$loaded().then(function(){for(var b=[],c=0;c<i.length;c++)i[c].artist&&i[c].artist.indexOf(a.artist.name)>-1&&b.push(i[c]);f(function(){a.movies=b})})["catch"](g)})["catch"](g)}]),angular.module("myMDApp").controller("GenresCtrl",["$scope","Ref","$firebaseArray","$timeout",function(a,b,c,d){function e(b){a.err=b,d(function(){a.err=null},5e3)}a.genres=c(b.child("genres")),a.genres.$loaded()["catch"](e)}]),angular.module("myMDApp").controller("GenreShowCtrl",["$scope","$routeParams","Ref","$firebaseObject","$firebaseArray","$timeout",function(a,b,c,d,e,f){function g(b){a.err=b,f(function(){a.err=null},5e3)}var h=b.id;a.genre=d(c.child("genres/"+h));var i=e(c.child("movies"));a.genre.$loaded().then(function(){i.$loaded().then(function(){for(var b=[],c=0;c<i.length;c++)(i[c].genres&&i[c].genres.indexOf(a.genre.name)>-1||i[c].mainGenre===a.genre.name)&&b.push(i[c]);f(function(){a.movies=b})})["catch"](g)})["catch"](g)}]);