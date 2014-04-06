'use strict'

angular.module('scrumbleApp')
  .factory 'Auth', ($http, $rootScope, ApiRoot, Project) ->
    auth =
      login: (username, password) ->
        $http.post(ApiRoot + '/api/login',
          username: username
          password: password
        ).then ->
          auth.loadCurrentUser()

      logout: ->
        $http.post(ApiRoot + '/api/logout').then ->
          $rootScope.currentUser = null

      loadCurrentUser: ->
        $http.get(ApiRoot + '/api/user').then (res) ->
          $rootScope.currentUser = res.data
          Project.query (projects) ->
            $rootScope.currentUser.projects = _.indexBy projects, 'id'
            if (projects.length > 0)
              $rootScope.currentUser.activeProject = projects[0].id

  .run (Auth, $rootScope, $location) ->
    Auth.loadCurrentUser().then((->), ->
      $location.path('/login')
    )
