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

    $scope.changeEstimate = (story) ->
      modalInstance = $modal.open(
        templateUrl: 'views/product-story-estimate-modal.html'
        controller: 'ProductStoryEstimateModalCtrl'
        resolve:
          story: -> story
      )
      modalInstance.result.then ->
        # $scope.load()

    $scope.load()

  .controller 'ProductStoryAddModalCtrl', ($scope, $rootScope, $modalInstance, Story, growl) ->
    projectId = $rootScope.currentUser.activeProject

    $scope.story = new Story
    $scope.story.tests = [{test: ''}]
    $scope.story.priority = 'MustHave'
    $scope.story.businessValue = 0
    $scope.story.project = projectId

    $scope.autoError = {}
    $scope.addTest = ->
      $scope.story.tests.push({test: ''})

    $scope.addStory = (invalid) ->
      if (invalid)
        return
      s = new Story()
      s.description = ''
      angular.extend(s, $scope.story)
      s.tests = _.filter(_.map $scope.story.tests, (t) -> t.test)

      s.$save projectId: projectId, ->
        $modalInstance.close()

        growl.addSuccessMessage("Story has been added.")
        $scope.autoError.removeErrors()
      , (reason) ->
        growl.addErrorMessage($scope.$root.backupError(reason.data.message, "An error occured while adding story"))
        $scope.autoError.showErrors(reason.data)

    $scope.cancel = ->
      $modalInstance.dismiss()

  .controller 'ProductStoryEstimateModalCtrl', ($scope, $rootScope, $modalInstance, Story, growl, story) ->
    $scope.story = story

    $scope.estimate =
      estimate: 0

    $scope.save = (invalid) ->
      return if invalid

      $scope.story.estimate = $scope.estimate.estimate

      $modalInstance.close()

      growl.addSuccessMessage("Estimate has been saved.")

    $scope.cancel = ->
      $modalInstance.dismiss()
