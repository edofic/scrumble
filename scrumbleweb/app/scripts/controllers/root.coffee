'use strict'

angular.module('scrumbleApp')
  .controller 'RootCtrl', ($scope, $route) ->
    # array keeps order
    $scope.navigationPaths = [
      {path: '/daily', name: 'Daily'}
      {path: '/sprint', name: 'Sprint'}
      {path: '/product', name: 'Product'}
    ]

    $scope.route = $route;
    $scope.isActivePath = (path) ->
      if($route.current && $route.current.$$route)
        path == $route.current.$$route.originalPath

    $scope.canShowNav = -> $scope.currentUser
    $scope.isAdmin = -> $scope.currentUser.role == 'Administrator'

    # $scope.notify('hello', 'success'/'danger')
    $scope.notifications = []
    $scope.closeNotification = (ix) -> $scope.notifications.splice(ix, 1)
    $scope.notify = (text, type) -> $scope.notifications.push {'text': text, 'type': type}

    # $scope.needsAdmin('You need to be admin')
    $scope.needsAdmin = (orMessage) ->
      checkRole = (role) ->
        if (role)
          removeWatcher()
          if (role != 'Administrator')
            $scope.notify(orMessage, 'danger')

      removeWatcher = $scope.$watch 'currentUser.role', checkRole
      checkRole($scope.currentUser && $scope.currentUser.role)
