'use strict'

angular.module('scrumbleApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'ngRoute',
  'ui.bootstrap'
])
  .config ($routeProvider, $httpProvider) ->
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
      .when '/login',
        templateUrl: 'views/login.html'
        controller: 'LoginCtrl'
      .when '/logout',
        templateUrl: 'views/logout.html'
        controller: 'LogoutCtrl'
      .otherwise
        redirectTo: '/'

    # comment this out to use apiary
    $httpProvider.defaults.withCredentials = true
    $httpProvider.defaults.useXDomain = true
    delete $httpProvider.defaults.headers.common['X-Requested-With']
