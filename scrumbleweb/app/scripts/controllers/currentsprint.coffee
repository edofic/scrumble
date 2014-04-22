'use strict'

angular.module('scrumbleApp')
  .controller 'CurrentSprintCtrl', ($scope, $filter, $rootScope, Sprint, Story, User, growl) ->

    $scope.statusColor =
      'Unassigned': 'danger'
      'Assigned': 'warning'
      'Accepted': 'primary'
      'Completed': 'success'

    User.query (data) ->
      $scope.allUsers = _.indexBy data, 'id'

    $scope.$watchCollection 'sprints', ->
      sortedSprints = $filter('orderBy')($scope.sprints, 'start')

      currSprintIx = _.findIndex sortedSprints, (sprint) ->
        (sprint.start < $scope.today) and ($scope.today < sprint.end)

      $scope.currentSprint = sortedSprints[currSprintIx]

      if $scope.currentSprint?
        $scope.currentSprint.number = currSprintIx + 1

        #   TODO: use only stories inside this sprint
        # SprintStories.get sprintId: $scope.currentSprint.id, (stories) ->
        Story.query projectId: $rootScope.currentUser.activeProject, (stories) -> # TODO: remove
          $scope.currentSprint.stories = stories

          _.each stories, (story) ->
            # TODO: use api..
            # StoryTasks.get storyId: story.id, (tasks) ->
            #  story.tasks = tasks
            story.tasks = [
              task: 'backend implementation'
              userId: 1
              status: 'Assigned'
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

