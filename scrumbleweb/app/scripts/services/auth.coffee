'use strict'

angular.module('scrumbleApp')
  .factory 'Auth', ($http) ->
    login: (username, password) ->
      $http.post 'http://scrumble.lukazakrajsek.com/api/login',
        username: username
        password: password

    logout: ->
      $http.post 'http://scrumble.lukazakrajsek.com/api/logout'

    currentUser: ->
      $http.get 'http://scrumble.lukazakrajsek.com/api/user'

  .run (Auth, $rootScope) ->
    Auth.login('test', 'test').then ->
      Auth.currentUser().then (res) ->
        $rootScope.user = res.data
