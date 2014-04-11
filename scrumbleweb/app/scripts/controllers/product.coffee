'use strict'

angular.module('scrumbleApp')
  .controller 'ProductCtrl', ($scope, $rootScope, $modal, Story, Project, ProjectUser, growl) ->
    projectId = $rootScope.currentUser.activeProject

    $scope.canEdit = no

    ProjectUser.get projectId: projectId, userId: $rootScope.currentUser.id, (projectUser) ->
      $scope.canEdit = ('ProductOwner' in projectUser.roles) || ('ScrumMaster' in projectUser.roles)

    $scope.load = ->
      $scope.stories = Story.query projectId: projectId

    $scope.addStory = ->
      modalInstance = $modal.open(
        templateUrl: 'views/product-story-add-modal.html'
        controller: 'ProductStoryAddModalCtrl'
      )
      modalInstance.result.then ->
        $scope.load()

    $scope.load()

  .controller 'ProductStoryAddModalCtrl', ($scope, $rootScope, $modalInstance, Story, growl) ->
    projectId = $rootScope.currentUser.activeProject

    $scope.story = new Story
    $scope.story.tests = [{test: ''}]
    $scope.story.priority = 'MustHave'
    $scope.story.businessValue = 0
    $scope.story.project = projectId

    $scope.addTest = ->
      $scope.story.tests.push({test: ''})

    $scope.addStory = ->
      s = new Story()
      angular.extend(s, $scope.story)
      s.tests = _.filter(_.map $scope.story.tests, (t) -> t.test)

      s.$save projectId: projectId, ->
        $modalInstance.close()

        growl.addSuccessMessage("Story has been added.")
      , (reason) ->
        growl.addErrorMessage($scope.$root.backupError(reason.data.message, "An error occured while adding story"))

    $scope.cancel = ->
      $modalInstance.dismiss()
