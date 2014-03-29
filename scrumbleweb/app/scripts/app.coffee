'use strict'

angular.module('scrumbleApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'ngRoute'
])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/project.html'
        controller: 'ProjectCtrl'
      .when '/meetings',
        templateUrl: 'views/meetings.html'
        controller: 'MeetingsCtrl'
      .when '/users',
        templateUrl: 'views/users.html'
        controller: 'UsersCtrl'
      .otherwise
        redirectTo: '/'
