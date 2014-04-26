'use strict'

angular.module('scrumbleApp')
  .controller 'CurrentSprintCtrl', ($scope, $filter, $rootScope, $modal, Sprint, Story, User, growl) ->
    projectId = $scope.currentUser.activeProject

    $scope.statusColor =
      'Unassigned': 'danger'
      'Assigned': 'warning'
      'Accepted': 'primary'
      'Completed': 'success'

    getAllDevs = ->
      projectUsers = $scope.currentUser.projects[projectId].users
      devs = _.filter projectUsers, (user) -> 'Developer' in user.roles
      _.map devs, (user) -> $scope.allUsers[user.user]

    User.query (data) ->
      $scope.allUsers = _.indexBy data, 'id'
      $scope.allDevs = getAllDevs()

    $scope.load = ->
      #   TODO: use only stories inside this sprint
      # SprintStories.get sprintId: $scope.currentSprint.id, (stories) ->
      Story.query projectId: projectId, (stories) -> # TODO: remove
        $scope.currentSprint.stories = stories

        _.each stories, (story) ->
          # TODO: use api..
          # StoryTasks.get {projectId: projectId, storyId: story.id}, (tasks) ->
          #  story.tasks = tasks
          story.tasks = [
            task: 'backend implementation'
            userId: 1
            status: 'Accepted'
            remaining: 3
          ,
            task: 'frontend implementation'
            userId: 2
            status: 'Completed'
            remaining: 0
          ,
            task: 'db schema'
            userId: 1
            status: 'Assigned'
            remaining: 1
          ,
            task: 'frontend validation'
            status: 'Unassigned'
            remaining: 2
          ]

    $scope.$watchCollection 'sprints', ->
      sortedSprints = $filter('orderBy')($scope.sprints, 'start')

      currSprintIx = _.findIndex sortedSprints, (sprint) ->
        (sprint.start < $scope.today) and ($scope.today < sprint.end)

      $scope.currentSprint = sortedSprints[currSprintIx]

      if $scope.currentSprint?
        $scope.currentSprint.number = currSprintIx + 1
        $scope.load()

    $scope.addTask = (storyId) ->
      modalInstance = $modal.open(
        templateUrl: 'views/task-add-modal.html'
        controller: 'TaskAddModalCtrl'
        resolve:
          projectId: -> projectId
          storyId: -> storyId
          allDevs: -> $scope.allDevs
      )
      modalInstance.result.then ->
        $scope.load()

  .controller 'TaskAddModalCtrl', ($scope, $rootScope, $modalInstance, growl, projectId, storyId, allDevs) ->

    $scope.allDevs = allDevs
    # TODO: use api
    $scope.task = {} # new Task()

    $scope.autoError = {}
    $scope.saveTask = (invalid) ->
      if (invalid)
        return

      $scope.task.status = 'Unassigned'

      if $scope.task.user?
        $scope.task.userId = $scope.task.user.id
        $scope.task.status = 'Assigned'

      # TODO: use api
      $scope.task.$save {projectId: projectId, storyId: storyId}, ->
        $modalInstance.close()

        growl.addSuccessMessage("Task has been added.")
        $scope.autoError.removeErrors()
      , (reason) ->
        growl.addErrorMessage($scope.$root.backupError(reason.data.message, "An error occured while adding task"))
        $scope.autoError.showErrors(reason.data)

    $scope.cancel = ->
      $modalInstance.dismiss()
