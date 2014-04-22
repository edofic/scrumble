'use strict'

angular.module('scrumbleApp')
  .controller 'CurrentSprintCtrl', ($scope, $filter, Sprint, growl) ->

    $scope.$watchCollection 'sprints', ->
      currSprintIx = _.findIndex $scope.sprints, (sprint) ->
        (sprint.start < $scope.today) and ($scope.today < sprint.end)

      $scope.currentSprint = $scope.sprints[currSprintIx]

      if $scope.currentSprint?
        $scope.currentSprint.number = currSprintIx + 1

        SprintStories?.get sprintId: $scope.currentSprint.id, (stories) ->
          $scope.currentSprint.stories = stories

          _.each stories, (story) ->
            StoryTasks?.get storyId: story.id, (tasks) ->
              story.tasks = tasks

