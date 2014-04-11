'use strict'

angular.module('scrumbleApp')
  .controller 'ProjectsCtrl', ($scope, Project, growl, bbox) ->
    $scope.needsAdmin('You don\'t have permission to manage projects')

    $scope.load = ->
      $scope.projects = Project.query()

    $scope.autoError = {}
    $scope.createProject = ->
      bbox.prompt 'New project name:', (projectName) ->
        return if not projectName

        project = new Project
        project.name = projectName

        project.$save (data) ->
          $scope.projects.push(data)
          $scope.load()

          growl.addSuccessMessage("Added project #{data.name}")
        , (reason) ->
          growl.addErrorMessage($scope.backupError(reason.data.message || reason.data.name, "An error occured while creating project"))

    $scope.load()
