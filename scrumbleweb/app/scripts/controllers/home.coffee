'use strict'

angular.module('scrumbleApp')
  .controller 'HomeCtrl', ($scope, $rootScope, ProjectUser) ->
    $scope.isActive = (project) ->
      $rootScope.currentUser.activeProject == project.id

    $scope.chooseProject = (project) ->
      $rootScope.currentUser.activeProject = project.id
      localStorage.activeProject = project.id

    $scope.isScrum = (roles) ->
      roles && ('ScrumMaster' in roles)
