'use strict';

angular.module('scrumbleFrontendApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'ngRoute'
])
  .config(function ($routeProvider) {
    $routeProvider
      .when('/', {
        templateUrl: 'views/main.html',
        controller: 'MainCtrl'
      })
      .when('/meeting', {
        templateUrl: 'views/meeting.html',
        controller: 'MeetingCtrl'
      })
      .otherwise({
        redirectTo: '/'
      });
  });
