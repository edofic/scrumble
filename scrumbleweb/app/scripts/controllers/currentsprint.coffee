'use strict'

angular.module('scrumbleApp')
  .controller 'CurrentSprintCtrl', ($scope, $filter, $rootScope, $modal, $q, Sprint, Story, SprintStory, Task, User, growl, bbox) ->
    projectId = $scope.currentUser.activeProject

    $scope.statusColor =
      'Unassigned': 'danger'
      'Assigned': 'warning'
      'Accepted': 'primary'
      'Completed': 'success'

    getAllDevs = ->
      projectUsers = $scope.currentUser.projects[projectId].users
      devs = _.filter projectUsers, (user) -> 'Developer' in user.roles
      _.map devs, (user) ->
        u = $scope.allUsers[user.user]
        u.joinedName = $scope.$root.formatUser(u)
        u

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

    $scope.taskComplete = (task, story) ->
      task.status = 'Completed'
      task.$update
        projectId: projectId
        sprintId: $scope.currentSprint.id
        storyId: story.id
        taskId: task.id
      , null
      , (reason) ->
        growl.addErrorMessage($scope.$root.backupError(reason.data.message, "An error occured while editing a task"))
        $scope.load()

    $scope.storyIsCompleted = (story) ->
      story.tasks? and story.tasks.length > 0 and _.all story.tasks, (task) -> task.status == 'Completed'

    $scope.logTime = (task, story) ->
      modalInstance = $modal.open(
        templateUrl: 'views/task-time-modal.html'
        controller: 'TaskTimeModalCtrl'
        resolve:
          task: -> task
          sprint: -> $scope.currentSprint
      )
      modalInstance.result.then ->
        task.$update
          projectId: projectId
          sprintId: $scope.currentSprint.id
          storyId: story.id
          taskId: task.id
        , $scope.load
        , (reason) ->
          growl.addErrorMessage($scope.$root.backupError(reason.data.message, "An error occured while editing a task"))
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

      if !taskCopy.user? || !_.isObject(taskCopy.user)
        delete taskCopy.user
      if taskCopy.user?
        taskCopy.userId = taskCopy.user.id
        taskCopy.user = taskCopy.user.id
        taskCopy.status = 'Assigned'

      taskCopy.history = [
        time: new Date().getTime()
        done: 0
        remaining: taskCopy.remaining
      ]

      delete taskCopy.remaining

      taskCopy.$save {projectId: projectId, sprintId: sprintId, storyId: storyId}, ->
        $modalInstance.close()

        growl.addSuccessMessage("Task has been added.")
        $scope.autoError.removeErrors()
      , (reason) ->
        growl.addErrorMessage($scope.$root.backupError(reason.data.message, "An error occured while adding task"))
        $scope.autoError.showErrors(reason.data)

    $scope.cancel = ->
      $modalInstance.dismiss()

  .controller 'TaskTimeModalCtrl', ($scope, $rootScope, $modalInstance, Story, growl, task, sprint) ->
    $scope.task = task
    $scope.sprint = sprint

    tsToStr = (ts) ->
      d = new Date(ts)
      d.getFullYear() + '-' + (d.getMonth() + 1) + '-' + d.getDay()

    timeMap = _.indexBy task.history, (x) -> tsToStr(x.time)

    $scope.history = []

    end = Math.min(new Date().getTime(), sprint.end)
    last = _.sortBy(task.history, (x) -> x.time)[0]
    time = last.time
    lastRemaining = last.remaining

    while time <= end
      existing = timeMap[tsToStr(time)]

      entry = if existing?
        time: existing.time
        done: existing.done
        remaining: existing.remaining
      else
        time: time
        done: 0
        remaining: lastRemaining

      $scope.history.unshift entry

      lastRemaining = entry.remaining

      time += 24 * 60 * 60 * 1000

    $scope.remainingChanged = (entry) ->
      _.each $scope.history, (x) ->
        if x.time > entry.time
          x.remaining = entry.remaining

    $scope.save = (invalid) ->
      return if invalid

      $scope.task.history = $scope.history

      $modalInstance.close()

    $scope.cancel = ->
      $modalInstance.dismiss()
