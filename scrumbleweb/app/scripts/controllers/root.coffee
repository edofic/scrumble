'use strict'

angular.module('scrumbleApp')
  .controller 'RootCtrl', ($scope, $route) ->
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
