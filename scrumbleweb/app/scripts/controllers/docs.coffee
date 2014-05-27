'use strict'

angular.module('scrumbleApp')
  .controller 'DocsCtrl', ($scope, $rootScope, ProjectDocs) ->
    projectId = $rootScope.currentUser.activeProject

    $scope.load = ->
      $scope.docs = ProjectDocs.get projectId: projectId

    $scope.load()

    $scope.editing = no

    $scope.edit = ->
      $scope.editing = yes
      $scope.docsEdit =
        content: $scope.docs.content

    $scope.editDone = ->
      $scope.docs.content = $scope.docsEdit.content

      $scope.docs.$update
        projectId: projectId
      , ->
        $scope.editing = no
        $scope.load

    $scope.editCancel = ->
      $scope.editing = no
