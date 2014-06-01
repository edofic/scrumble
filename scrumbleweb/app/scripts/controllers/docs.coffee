'use strict'

angular.module('scrumbleApp')
  .controller 'DocsCtrl', ($scope, $rootScope, $modal, ProjectDocs) ->
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

    $scope.generate = ->
      modalInstance = $modal.open(
        templateUrl: 'views/docs-generate-modal.html'
        controller: 'DocsGenerateModalCtrl'
      )
      modalInstance.result.then (data) ->
        storiesTexts = []

        elements = _.object(_.map(data.elements, (x) -> [x, yes]))

        _.each data.stories, (story) ->
          parts = []

          if elements.title
            parts.push("## #{story.title}")

          if elements.description
            if story.description.trim()
              parts.push("**#{story.description}**")

          if elements.tests
            parts.push(_.map(story.tests, (x) -> '&#35; ' + x).join('\n\n'))

          if elements.notes
            parts.push(_.map(story.notes, (x) -> '-- ' + x).join('\n\n'))

          storiesTexts.push(_.filter(parts).join('\n\n'))

        text = storiesTexts.join('\n\n\n')

        if data.position == 'top'
          $scope.docsEdit.content = text + '\n\n\n' + $scope.docsEdit.content
        else
          $scope.docsEdit.content = $scope.docsEdit.content + '\n\n\n' + text

  .controller 'DocsGenerateModalCtrl', ($scope, $rootScope, $modalInstance, Story, growl) ->
    projectId = $rootScope.currentUser.activeProject

    $scope.positions = [
      position: 'top'
      text: 'at the top of the document'
    ,
      position: 'bottom'
      text: 'at the bottom of the document'
    ]
    $scope.elements = [
      element: 'title'
      text: 'Title'
    ,
      element: 'description'
      text: 'Description'
    ,
      element: 'tests'
      text: 'Acceptance tests'
    ,
      element: 'notes'
      text: 'Notes'
    ]

    $scope.stories = []

    Story.query projectId: projectId, (stories) ->
      $scope.stories = stories

    $scope.data =
      position: 'bottom'
      stories: []
      elements: [
        'title'
        'description'
      ]

    $scope.selectAllStories = ->
      $scope.data.stories = $scope.stories.slice()

    $scope.generateSubmit = (invalid) ->
      return if invalid

      $modalInstance.close($scope.data)

    $scope.cancel = ->
      $modalInstance.dismiss()
