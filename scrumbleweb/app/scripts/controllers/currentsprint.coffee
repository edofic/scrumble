'use strict'

angular.module('scrumbleApp')
  .controller 'CurrentSprintCtrl', ($scope, $filter, $rootScope, $modal, Sprint, Story, SprintStory, Task, User, growl) ->
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
      SprintStory.query {projectId: projectId, sprintId: $scope.currentSprint.id}, (stories) ->
        $scope.currentSprint.stories = stories

        _.each stories, (story) ->
          Task.query {projectId: projectId, sprintId: $scope.currentSprint.id, storyId: story.id}, (tasks) ->
            story.tasks = tasks

          , (reason) ->
            growl.addErrorMessage($scope.$root.backupError(reason.data.message, "An error occured while loading tasks"))
      , (reason) ->
        growl.addErrorMessage($scope.$root.backupError(reason.data.message, "An error occured while loading stories"))


    $scope.$watchCollection 'sprints', ->
      sortedSprints = $filter('orderBy')($scope.sprints, 'start')

      currSprintIx = _.findIndex sortedSprints, (sprint) ->
        (sprint.start < $scope.today) and ($scope.today < sprint.end)

      $scope.currentSprint = null

      if currSprintIx >= 0
        $scope.currentSprint = sortedSprints[currSprintIx]
        $scope.currentSprint.number = currSprintIx + 1
        $scope.load()

    $scope.addTask = (storyId) ->
      modalInstance = $modal.open(
        templateUrl: 'views/task-add-modal.html'
        controller: 'TaskAddModalCtrl'
        resolve:
          projectId: -> projectId
          sprintId: -> $scope.currentSprint.id
          storyId: -> storyId
          allDevs: -> $scope.allDevs
      )
      modalInstance.result.then ->
        $scope.load()


    $scope.taskTake = (task, story) ->
      task.user = $scope.currentUser.id
      task.userId = $scope.currentUser.id
      task.status = 'Accepted'
      task.$update
        projectId: projectId
        sprintId: $scope.currentSprint.id
        storyId: story.id
        taskId: task.id
      , null
      , (reason) ->
        growl.addErrorMessage($scope.$root.backupError(reason.data.message, "An error occured while editing a task"))
        $scope.load()


    $scope.taskRelease = (task, story) ->
      delete task.user
      delete task.userId
      task.status = 'Unassigned'
      task.$update
        projectId: projectId
        sprintId: $scope.currentSprint.id
        storyId: story.id
        taskId: task.id
      , null
      , (reason) ->
        growl.addErrorMessage($scope.$root.backupError(reason.data.message, "An error occured while editing a task"))
        $scope.load()

    $scope.storyRemainingSum = (story) ->
      _.reduce story.tasks, (sum, task) ->
        sum + task.remaining
      , 0
    $scope.acceptStory = (story) ->
      storyStory = new Story()
      story.done = true
      angular.extend storyStory, story
      storyStory.$update
        projectId: projectId
        storyId: storyStory.id
      , null
      , (reason) ->
        growl.addErrorMessage($scope.$root.backupError(reason.data.message, "An error occured while accepting a story"))
        $scope.load()
    $scope.rejectStory = (story) ->
      sprintId = story.sprint
      story.sprint = null
      sprintStory = new SprintStory()
      sprintStory.$delete
        projectId: projectId
        sprintId: sprintId
        storyId: story.id
      , $scope.load
      , (reason) ->
        growl.addErrorMessage($scope.$root.backupError(reason.data.message, "An error occured while rejecting a story"))
        $scope.load()


  .controller 'TaskAddModalCtrl', ($scope, $rootScope, $modalInstance, Task, growl, projectId, sprintId, storyId, allDevs) ->

    $scope.allDevs = allDevs
    $scope.task = new Task()

    $scope.autoError = {}
    $scope.saveTask = (invalid) ->
      if (invalid)
        return

      taskCopy = angular.copy $scope.task
      taskCopy.status = 'Unassigned'

      if taskCopy.user?
        taskCopy.userId = taskCopy.user.id
        taskCopy.user = taskCopy.user.id
        taskCopy.status = 'Assigned'

      taskCopy.remaining = taskCopy.remaining * 100

      # TODO: use api
      taskCopy.$save {projectId: projectId, sprintId: sprintId, storyId: storyId}, ->
        $modalInstance.close()

        growl.addSuccessMessage("Task has been added.")
        $scope.autoError.removeErrors()
      , (reason) ->
        growl.addErrorMessage($scope.$root.backupError(reason.data.message, "An error occured while adding task"))
        $scope.autoError.showErrors(reason.data)

    $scope.cancel = ->
      $modalInstance.dismiss()
