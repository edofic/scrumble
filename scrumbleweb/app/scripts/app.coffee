'use strict'

angular.module('scrumbleApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'ngRoute',
  'ui.bootstrap'
])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/project.html'
        controller: 'ProjectCtrl'
      .when '/daily',
        templateUrl: 'views/daily.html'
        controller: 'DailyCtrl'
      .when '/users',
        templateUrl: 'views/users.html'
        controller: 'UsersCtrl'
      .when '/projects',
        templateUrl: 'views/projects.html'
        controller: 'ProjectsCtrl'
      .otherwise
        redirectTo: '/'
