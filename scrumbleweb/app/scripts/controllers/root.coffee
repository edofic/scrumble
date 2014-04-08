'use strict'

angular.module('scrumbleApp')
  .controller 'RootCtrl', ($scope, $route, growl) ->
    # array keeps order
    $scope.navigationPaths = [
      {path: '/daily', name: 'Daily'}
      {path: '/sprint', name: 'Sprint'}
      {path: '/product', name: 'Product'}
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

    $scope.formatUser = (user) ->
      return if not user?

      "#{user.firstName} #{user.lastName}"

    $scope.userProjectRoles =
      Developer: 'Team member'
      ScrumMaster: 'Scrum master'
      ProductOwner: 'Product owner'

    $scope.storyPriorities = $scope.$root.storyPriorities =
      NotThisTime: 'Not this time'
      CouldHave: 'Could have'
      ShouldHave: 'Should have'
      MustHave: 'Must have'
