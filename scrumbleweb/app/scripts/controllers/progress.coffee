'use strict'

angular.module('scrumbleApp')
  .controller 'ProgressCtrl', ($scope, $q, Sprint, SprintStory, Story, Task, User, growl, bbox) ->
    projectId = $scope.currentUser.activeProject

    $scope.ptHour = 6

    $scope.allWork = []
    $scope.a = {}
    # a > sprints > a_stories > a_tasks > history

    storiesReq = Story.query {projectId: projectId}, (stories) ->
      $scope.a.stories = stories

    Sprint.query {projectId: projectId}, (sprints) ->
      $scope.a.sprints = sprints
      defers = _.map sprints, (sprint) ->
        tasksDone = $q.defer()
        SprintStory.query {projectId: projectId, sprintId: sprint.id}, (sprintStories) ->
          sprint.a_stories = sprintStories

          taskReqs = _.map sprintStories, (story) ->
            Task.query {projectId: projectId, sprintId: sprint.id, storyId: story.id}, (tasks) ->
              story.a_tasks = tasks

              hists = _.map tasks, (t) ->
                _.each t.history, (h) -> h.taskId = t.id
                t.history

              $scope.allWork.push hists
          $q.all(_.pluck(taskReqs, '$promise')).then ->
            tasksDone.resolve()
          , ->
            tasksDone.reject()
        tasksDone.promise
      $q.all(defers.concat(storiesReq.$promise)).then ->
        $scope.draw()


    time2day = (time) ->
      Math.floor(time/1000/60/60/24)

    $scope.calcDaily = ->
      estimates = _.compact _.pluck($scope.a.stories, 'points')
      initEstimate = _.reduce estimates, (sum, estim) ->
        sum + estim*$scope.ptHour
      , 0

      console.log 'initEstimate', initEstimate

      allTimes = _.pluck _.flatten($scope.allWork), 'time'
      firstDay = time2day(_.min(allTimes))-5
      lastDay = time2day(_.max(allTimes))+1

      today = time2day(Date.now())
      lastDay = today if today > lastDay

      processedStoryIDs = []
      processStory = (story) ->
        processedStoryIDs.push story.id

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


      allDailys = _.map $scope.a.sprints, (sprint) ->
        storyDailys = _.map sprint.a_stories, processStory
        sprint.a_dailys = _.flatten storyDailys

      toProcess = _.reject $scope.a.stories, (story) ->
        story.id in processedStoryIDs
      allDailys.push.apply allDailys, _.map(toProcess, processStory)


      flatDailys = _.flatten allDailys
      dailys = _.groupBy flatDailys, 'day'
      _.map dailys, (daily, day) ->
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

    $scope.draw = ->
      daily = $scope.calcDaily()
      allTimes = _.pluck _.flatten($scope.allWork), 'time'
      firstDay = time2day(_.min(allTimes))-1

      workloadFlot = _.map daily, (d) ->
        [d.day-firstDay+1, d.workload]
      remainingFlot = _.map daily, (d) ->
        [d.day-firstDay+1, d.remaining]

      $.plot '.flot', [workloadFlot, remainingFlot],
        xaxis:
          tickSize: 2
          tickDecimals: 0

    $scope.$watch 'ptHour', $scope.draw
