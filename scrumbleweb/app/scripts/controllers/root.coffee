'use strict'

angular.module('scrumbleApp')
  .controller 'RootCtrl', ($scope, $route, growl) ->
    # array keeps order
    $scope.navigationPaths = [
      {path: '/daily', name: 'Daily Scrum'}
      {path: '/sprint', name: 'Sprint Backlog'}
      {path: '/product', name: 'Product Backlog'}
      {path: '/progress', name: 'Progress'}
    ]

    $scope.route = $route

    $scope.isActivePath = (path) ->
      path == $route.current?.$$route?.originalPath

    $scope.canShowNav = -> $scope.currentUser
    $scope.isAdmin = -> $scope.currentUser.role == 'Administrator'

    # $scope.needsAdmin('You need to be admin')
    $scope.needsAdmin = (orMessage) ->
      checkRole = (role) ->
        if role
          removeWatcher()
          if role != 'Administrator'
            growl.addErrorMessage(orMessage)

      removeWatcher = $scope.$watch 'currentUser.role', checkRole
      checkRole($scope.currentUser && $scope.currentUser.role)

    $scope.$root.formatUser = $scope.formatUser = (user) ->
      return if not user?

      "#{user.firstName} #{user.lastName}"

    $scope.$root.backupError = (errorMessage, backupErrorMessage) ->
      if errorMessage? && errorMessage != 'Internal Server Error'
        errorMessage
      else
        backupErrorMessage

    $scope.filterDone = (arr) ->
      _.where arr, done: true
    $scope.filterNotDone = (arr) ->
      _.where arr, done: false

    $scope.$root.userProjectRolesOrdered = [
      {value: 'Developer', label: 'Team member'}
      {value: 'ScrumMaster', label: 'Scrum master'}
      {value: 'ProductOwner', label: 'Product owner'}
    ]
    $scope.$root.userProjectRoles = _.indexBy($scope.$root.userProjectRolesOrdered, 'value')

    $scope.$root.storyPrioritiesOrdered = [
      {value: 'MustHave', label: 'Must have'}
      {value: 'ShouldHave', label: 'Should have'}
      {value: 'CouldHave', label: 'Could have'}
      {value: 'NotThisTime', label: 'Not this time'}
    ]
    $scope.$root.storyPriorities = _.indexBy($scope.$root.storyPrioritiesOrdered, 'value')
