'use strict'

angular.module('scrumbleApp')
  .controller 'RootCtrl', ($scope, $route, Auth) ->
    $scope.navigationPaths =
      '/daily': 'Daily'
      '/sprint': 'Sprint'
      '/product': 'Product'

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
      removeWatcher = $scope.$watch 'currentUser.role', (role) ->
        if (role && (role != 'Administrator'))
          $scope.notify(orMessage, 'danger')
          removeWatcher()
