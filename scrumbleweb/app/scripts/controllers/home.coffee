'use strict'

angular.module('scrumbleApp')
  .controller 'HomeCtrl', ($scope, $rootScope) ->
    $scope.isActive = (project) ->
      $rootScope.currentUser.activeProject == project.id

    $scope.chooseProject = (project) ->
      $rootScope.currentUser.activeProject = project.id
