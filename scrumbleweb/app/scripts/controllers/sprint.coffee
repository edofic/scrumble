'use strict'

angular.module('scrumbleApp')
  .controller 'SprintCtrl', ($scope, $filter, Sprint, growl) ->

    $scope.dateOptions =
      'starting-day': 1
      'show-weeks': false

    $scope.today = Date.now()

    updateFromActiveProject = ->
      user = $scope.currentUser
      if(!user || !user.activeProject)
        return
      $scope.sprints = Sprint.query {projectId: user.activeProject}
      projectUsers = _.indexBy(user.projects[user.activeProject].users, 'username')
      isScrum = projectUsers[user.username] && projectUsers[user.username].scrumMaster

      isAdmin = user.role == 'Administrator'
      $scope.canCreateSprint = isAdmin || isScrum

    $scope.$watch 'currentUser.activeProject', updateFromActiveProject

    ### Wanted from API:
    [{
      start: 1393662209873
      end: 1396662209873   # end > start
      velocity: 20         # integer..
    }]
    ###

    $scope.createSprint = (sprint, invalid) ->
      if (invalid)
        return
      sprint.$save {projectId: $scope.currentUser.activeProject}, (data) ->
        $scope.sprints.push(data)
        $scope.initNewSprint()
        humanStart = $filter('date')(data.start, 'dd.MM.yyyy')
        humanEnd = $filter('date')(data.end, 'dd.MM.yyyy')
        growl.addSuccessMessage("Added sprint from #{humanStart} to #{humanEnd}")
      , (reason) ->
        growl.addErrorMessage(reason.data.message)

    $scope.initNewSprint = () ->
      $scope.sprint = new Sprint()

    $scope.initNewSprint()

    # SprintDays affects sprintEnd
    # WorkdayVelocity affects velocity
    calculatingFields = ->
      updateSprintDays = ->
        if ($scope.sprint.end && $scope.sprint.start)
          $scope.sprint.sprintDays = Math.round(($scope.sprint.end.getTime() - $scope.sprint.start.getTime())/1000/60/60/24)
      updateSprintEnd = ->
        if ($scope.sprint.start && $scope.sprint.sprintDays)
          $scope.sprint.end = new Date($scope.sprint.start.getTime() + $scope.sprint.sprintDays*1000*60*60*24)
      updateWorkdayVelocity = ->
        if ($scope.sprint.velocity && $scope.sprint.sprintDays)
          $scope.sprint.workdayVelocity = Math.round(($scope.sprint.velocity / ($scope.sprint.sprintDays*5/7))*100)/100
      updateVelocity = ->
        if ($scope.sprint.workdayVelocity && $scope.sprint.sprintDays)
          $scope.sprint.velocity = Math.round($scope.sprint.workdayVelocity * ($scope.sprint.sprintDays*5/7))

      $scope.$watch 'sprint.start', updateSprintDays
      $scope.$watch 'sprint.end', updateSprintDays
      $scope.$watch 'sprint.sprintDays', updateSprintEnd
      $scope.$watch 'sprint.sprintStart', updateSprintEnd
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
