'use strict'

angular.module('scrumbleApp')
  .controller 'SprintCtrl', ($scope, $filter, Sprint, growl) ->

    $scope.dateOptions =
      'starting-day': 1
      'show-weeks': false

    $scope.today = Date.now()
    $scope.addDays = (date, num) ->
      ret = new Date(date)
      ret.setDate(ret.getDate()+num)
      ret.getTime()

    $scope.isScrum = ->
      user = $scope.currentUser
      projectUsers = user.projects[user.activeProject].users
      projectUsers[user.id] && ('ScrumMaster' in projectUsers[user.id].roles)
    $scope.isDeveloper = ->
      user = $scope.currentUser
      projectUsers = user.projects[user.activeProject].users
      projectUsers[user.id] && ('Developer' in projectUsers[user.id].roles)
    $scope.isProduct = ->
      user = $scope.currentUser
      projectUsers = user.projects[user.activeProject].users
      projectUsers[user.id] && ('ProductOwner' in projectUsers[user.id].roles)

    updateFromActiveProject = ->
      user = $scope.currentUser
      if(!user || !user.activeProject)
        return
      $scope.sprints = Sprint.query {projectId: user.activeProject}

      isAdmin = user.role == 'Administrator'
      $scope.canCreateSprint = isAdmin || $scope.isScrum()

    $scope.$watch 'currentUser.activeProject', updateFromActiveProject

    $scope.autoError = {}
    $scope.createSprint = (sprint, invalid) ->
      if (invalid)
        return
      sprintCopy = angular.copy(sprint)
      sprintCopy.start = sprintCopy.start.getTime()
      sprintCopy.end = sprintCopy.end.getTime()
      sprintCopy.$save {projectId: $scope.currentUser.activeProject}, (data) ->
        $scope.sprints.push(data)
        $scope.initNewSprint()
        humanStart = $filter('date')(data.start, 'dd.MM.yyyy')
        humanEnd = $filter('date')(data.end, 'dd.MM.yyyy')
        growl.addSuccessMessage("Added sprint from #{humanStart} to #{humanEnd}")
        $scope.autoError.removeErrors()
      , (reason) ->
        growl.addErrorMessage($scope.backupError(reason.data.message, "An error occured while creating sprint"))
        $scope.autoError.showErrors(reason.data)

    $scope.initNewSprint = () ->
      $scope.sprint = new Sprint()

    $scope.initNewSprint()

    # SprintDays affects sprintEnd
    # WorkdayVelocity affects velocity
    calculatingFields = ->
      getWorkdays = (start, numDays) ->
        datesRange = _.range(start.getDay(), start.getDay()+numDays)
        workdays = _.reject datesRange, (day) ->
          mod = day % 7
          mod == 0 || mod == 6
        workdays.length

      updateSprintDays = ->
        if ($scope.sprint.end && $scope.sprint.start)
          $scope.sprint.sprintDays = Math.round(($scope.sprint.end.getTime() - $scope.sprint.start.getTime())/1000/60/60/24)
      updateSprintEnd = ->
        if ($scope.sprint.start && $scope.sprint.sprintDays)
          $scope.sprint.end = new Date($scope.sprint.start.getTime() + $scope.sprint.sprintDays*1000*60*60*24)
      updateWorkdayVelocity = ->
        if ($scope.sprint.velocity && $scope.sprint.sprintDays)
          workdays = getWorkdays($scope.sprint.start, $scope.sprint.sprintDays)
          if(workdays == 0)
            $scope.sprint.workdayVelocity = 0
          else
            $scope.sprint.workdayVelocity = Math.round($scope.sprint.velocity / workdays*100)/100
      updateVelocity = ->
        if ($scope.sprint.workdayVelocity && $scope.sprint.sprintDays)
          workdays = getWorkdays($scope.sprint.start, $scope.sprint.sprintDays)
          $scope.sprint.velocity = Math.round($scope.sprint.workdayVelocity * workdays)

      $scope.$watch 'sprint.start', updateSprintDays
      $scope.$watch 'sprint.end', updateSprintDays
      $scope.$watch 'sprint.sprintDays', updateSprintEnd
      $scope.$watch 'sprint.sprintStart', updateSprintEnd
      $scope.workdayVelocityEnable = false
      if ($scope.workdayVelocityEnable)
        $scope.$watch 'sprint.velocity', updateWorkdayVelocity
        $scope.$watch 'sprint.sprintDays', updateWorkdayVelocity
        $scope.$watch 'sprint.workdayVelocity', updateVelocity
        $scope.$watch 'sprint.sprintDays', updateVelocity

    calculatingFields()


  .directive 'dateLessThan', ->
    require: 'ngModel',
    link: (scope, elem, attrs, ctrl) ->
      validate = ->
        ctrl.$setValidity('dateLessThan', new Date(ctrl.$viewValue) < new Date(attrs.dateLessThan))
      scope.$watch attrs.ngModel, validate
      attrs.$observe 'dateLessThan', validate

  .directive 'dateParseInput', ->
    restrict: 'A'
    require: 'ngModel'
    link: (scope, elem, attrs, ctrl) ->
      ctrl.$parsers.unshift (viewValue) ->
        if(viewValue instanceof Date)
          return viewValue
        splitted = viewValue.split('.')
        convertedDate = splitted[1] + "/" + splitted[0] + "/" + splitted[2]
        return new Date(Date.parse(convertedDate))
