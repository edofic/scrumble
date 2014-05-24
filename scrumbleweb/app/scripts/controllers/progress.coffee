'use strict'

angular.module('scrumbleApp')
  .controller 'ProgressCtrl', ($scope, $q, Sprint, SprintStory, Story, Task, User, growl, bbox) ->
    projectId = $scope.currentUser.activeProject

    $scope.ptHour = 6

    $scope.allWork = []
    $scope.a = {}
    # a > sprints > a_stories > a_tasks > history

    Story.query {projectId: projectId}, (stories) ->
      $scope.a.stories = stories

    Sprint.query {projectId: projectId}, (sprints) ->
      $scope.a.sprints = sprints
      _.map sprints, (sprint) ->
        SprintStory.query {projectId: projectId, sprintId: sprint.id}, (sprintStories) ->
          sprint.a_stories = sprintStories

          _.map sprintStories, (story) ->
            Task.query {projectId: projectId, sprintId: sprint.id, storyId: story.id}, (tasks) ->
              story.a_tasks = tasks

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

    $scope.calc2 = ->
      estimates = _.compact _.pluck($scope.a.stories, 'points')
      initEstimate = _.reduce estimates, (sum, estim) ->
        sum + estim*$scope.ptHour

      console.log initEstimate

      # $scope.a.sprints[0].a_stories[10]
      # points: 4  =>  24h
      # _.pluck $scope.a.sprints[0].a_stories[10].a_tasks, 'history'
      storyAllWork = _.pluck($scope.a.sprints[0].a_stories[10].a_tasks, 'history')

      storyDaily = _.groupBy _.flatten(storyAllWork), (w) ->
        Math.floor(w.time/1000/60/60/24)
      storyDaily = _.mapValues storyDaily, (w) ->
        work: w

      storyDaily

      console.log storyDaily
      work = storyDaily['16195'].work
      console.log work
      console.log _.pluck(work, 'taskId')
      console.log 'Why are there multiple work history logs on same task on the same day? ... Taking last instance..' if _.pluck(work, 'taskId').length != _.unique(_.pluck(work, 'taskId')).length

      cleanWork = {}
      cleanWork.work = _.values _.indexBy(work, 'taskId')
      tempdone = _.reduce cleanWork.work, (sum, work) ->
        sum + work.done
      , 0
      cleanWork.remaining = _.reduce cleanWork.work, (sum, work) ->
        sum + work.remaining
      , 0
      cleanWork.workload = tempdone + cleanWork.remaining
      cleanWork









