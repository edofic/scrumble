'use strict'

angular.module('scrumbleApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'ngRoute',
  'ui.bootstrap',
  'angular-growl'
])
  .config ($routeProvider, $httpProvider) ->
    currentUser = ['$rootScope', '$location', '$q', ($rootScope, $location, $q) ->
      $rootScope.currentUserPromise.then ->
        if not $rootScope.currentUser
          $location.url('/login')
          $q.defer().promise
        else
          $rootScope.currentUser
    ]

    loginRequired =
      currentUser: currentUser

    $routeProvider
      .when '/login',
        templateUrl: 'views/login.html'
        controller: 'LoginCtrl'
      .when '/logout',
        templateUrl: 'views/logout.html'
        controller: 'LogoutCtrl'
      .when '/',
        templateUrl: 'views/home.html'
        controller: 'HomeCtrl'
        resolve: loginRequired
      .when '/daily',
        templateUrl: 'views/daily.html'
        controller: 'DailyCtrl'
        resolve: loginRequired
      .when '/users',
        templateUrl: 'views/users.html'
        controller: 'UsersCtrl'
        resolve: loginRequired
      .when '/projects',
        templateUrl: 'views/projects.html'
        controller: 'ProjectsCtrl'
        resolve: loginRequired
      .when '/projects/:projectId',
        templateUrl: 'views/project.html'
        controller: 'ProjectCtrl'
        resolve: loginRequired
      .when '/sprint',
        templateUrl: 'views/sprint.html'
        controller: 'SprintCtrl'
        resolve: loginRequired
      .when '/product',
        templateUrl: 'views/product.html'
        controller: 'ProductCtrl'
        resolve: loginRequired
      .otherwise
        redirectTo: '/'

    # comment this out to use apiary
    $httpProvider.defaults.withCredentials = true
    $httpProvider.defaults.useXDomain = true
    delete $httpProvider.defaults.headers.common['X-Requested-With']

  .config (growlProvider) ->
    growlProvider.globalTimeToLive 3000
