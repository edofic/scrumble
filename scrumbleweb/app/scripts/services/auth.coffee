'use strict'

angular.module('scrumbleApp')
  .factory 'Auth', ($http, $rootScope, $q, ApiRoot, Project) ->
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
        defer = $q.defer()

        if not $rootScope.currentUserPromise
          $rootScope.currentUserPromise = defer.promise

        $http.get(ApiRoot + '/api/user').then (res) ->
          $rootScope.currentUser = res.data
          Project.query (projects) ->
            $rootScope.currentUser.projects = _.indexBy projects, 'id'
            if (projects.length > 0)
              $rootScope.currentUser.activeProject = projects[0].id

            defer.resolve()
        , (reason) ->
          defer.resolve()

  .run (Auth, $rootScope, $location) ->
    Auth.loadCurrentUser()
