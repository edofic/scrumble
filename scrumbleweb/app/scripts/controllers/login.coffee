'use strict'

angular.module('scrumbleApp')
  .controller 'LoginCtrl', ($scope, $location, Auth) ->
    $scope.login = ->
      Auth.login($scope.username, $scope.password).then ->
        $location.path('/')
      , (reason) ->
        $scope.notify(reason.data.message, 'danger')
