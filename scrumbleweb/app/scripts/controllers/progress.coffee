'use strict'

angular.module('scrumbleApp')
  .controller 'ProgressCtrl', ($scope, $q, Sprint, SprintStory, Task, User, growl, bbox) ->
    projectId = $scope.currentUser.activeProject

    $scope.allWork = [];
    Sprint.query {projectId: projectId}, (sprints) ->
      _.map sprints, (sprint) ->
        SprintStory.query {projectId: projectId, sprintId: sprint.id}, (sprintStories) ->

          _.map sprintStories, (story) ->
            Task.query {projectId: projectId, sprintId: sprint.id, storyId: story.id}, (tasks) ->
              hists = _.map tasks, (t) ->
                _.each t.history, (h) -> h.taskId = t.id
                t.history

              $scope.allWork.push hists

    $scope.calc = ->
      work = _.flatten $scope.allWork
      perDay = _.groupBy work, (w) ->
        Math.floor(w.time/1000/60/60/24)

      sums = _.map perDay, (day) ->
        done = _.reduce day, (sum, work) ->
          sum + work.done
        , 0
        remaining = _.reduce day, (sum, work) ->
          sum + work.remaining
        , 0
        return {
          done: done
          remaining: remaining
          onTasks: _.unique _.pluck day, 'taskId'
        }

      dailySums = _.zip _.keys(perDay), sums
      dailySums = _.map dailySums, (s) ->
        day: s[0]
        sum: s[1]
      dailySums = _.sortBy dailySums, 'day'
      $scope.dailySum = dailySums


    # estimate to hours? || remaining - done


