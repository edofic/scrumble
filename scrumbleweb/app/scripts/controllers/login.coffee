'use strict'

angular.module('scrumbleApp')
  .controller 'LoginCtrl', ($scope, $location, Auth, growl) ->
    $scope.login = ->
      Auth.login($scope.username, $scope.password).then ->
        $location.path('/')
      , (reason) ->
        growl.addErrorMessage(reason.data.message || "An error occured while logging in")
