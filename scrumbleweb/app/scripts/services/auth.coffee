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

            $rootScope.currentUser.activeProject = _.find projects, (x) -> x.id == (localStorage.activeProject >> 0)

            if $rootScope.currentUser.activeProject?
              $rootScope.currentUser.activeProject = $rootScope.currentUser.activeProject.id

            if not $rootScope.currentUser.activeProject? and projects.length > 0
              $rootScope.currentUser.activeProject = projects[0].id
              localStorage.activeProject = $rootScope.currentUser.activeProject

            defer.resolve()
        , (reason) ->
          defer.resolve()

  .run (Auth, $rootScope, $location) ->
    Auth.loadCurrentUser()
