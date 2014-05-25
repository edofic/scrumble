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

    time2day = (time) ->
      Math.floor(time/1000/60/60/24)

    $scope.calc = ->
      work = _.flatten $scope.allWork
      perDay = _.groupBy work, (w) -> time2day(w.time)

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

      console.log 'initEstimate', initEstimate

      allTimes = _.pluck _.flatten($scope.allWork), 'time'
      firstDay = time2day(_.min(allTimes))-1
      lastDay = time2day(_.max(allTimes))+1

      today = time2day(Date.now())
      lastDay = today if today > lastDay

      # $scope.a.sprints[0].a_stories[10]
      # points: 4  =>  24h
      # _.pluck $scope.a.sprints[0].a_stories[10].a_tasks, 'history'
      _.each $scope.a.sprints, (sprint) ->
        storyDailys = _.map sprint.a_stories, (story) ->
          storyAllWork = _.flatten _.pluck(story.a_tasks, 'history')

          storyDays = _.map storyAllWork, (w) -> time2day(w.time)

          storyDaily = _.groupBy storyAllWork, (w) -> time2day(w.time)
          storyDaily = _.mapValues storyDaily, (work, day) ->
            console.log 'Why are there multiple work history logs on same task on the same day? ... Taking last instance..' if _.pluck(work, 'taskId').length != _.unique(_.pluck(work, 'taskId')).length

            cleanWork = _.values _.indexBy(work, 'taskId')
            tempdone = _.reduce cleanWork, (sum, work) ->
              sum + work.done
            , 0
            remaining = _.reduce cleanWork, (sum, work) ->
              sum + work.remaining
            , 0
            workload = tempdone + remaining

            return {
              work: work
              workload: workload
              remaining: remaining
              day: parseInt(day)
            }

          estimEnd = lastDay
          estimEnd = _.min(storyDays) if storyDays.length > 0

          estimateDays = _.range firstDay, estimEnd
          estimatedRemaining = story.points * $scope.ptHour
          preWork = _.map estimateDays, (day) ->
            workload: estimatedRemaining
            remaining: estimatedRemaining
            day: day
          return preWork if storyDays.length <= 0

          dragDays = _.range lastDay, _.max(storyDays)
          dragRemaining = storyDaily[_.max(storyDays)].remaining
          dragWorkload = storyDaily[_.max(storyDays)].workload
          postWork = _.map dragDays, (day) ->
            workload: dragWorkload
            remaining: dragRemaining
            day: day

          return preWork.concat(_.values(storyDaily), postWork)

        storyDailys = _.groupBy _.flatten(storyDailys), 'day'

        sprint.a_dailys = _.map storyDailys, (daily, day) ->
          remaining = _.reduce daily, (sum, work) ->
            sum + work.remaining
          , 0
          workload = _.reduce daily, (sum, work) ->
            sum + work.workload
          , 0
          return {
            day: parseInt(day)
            workload: workload
            remaining: remaining
            daily: daily
          }
        console.log(sprint.a_dailys)







