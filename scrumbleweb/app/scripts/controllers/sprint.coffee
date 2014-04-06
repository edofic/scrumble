'use strict'

angular.module('scrumbleApp')
  .controller 'SprintCtrl', ($scope, $filter, Sprint) ->
    # TODO: use activeProjectId which will probably be in $root
    $scope.projectId = 1;
    # TODO: is scrum master in this project?
    $scope.canCreateSprint = -> true

    $scope.dateOptions =
      'starting-day': 1
      'show-weeks': false

    $scope.today = Date.now()

    # TODO: fix if projectId is async...
    $scope.sprints = Sprint.query {projectId: $scope.projectId}
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
      sprint.$save {projectId: $scope.projectId}, (data) ->
        $scope.sprints.push(data)
        $scope.initNewSprint()
        humanStart = $filter('date')(data.start, 'dd.MM.yyyy')
        humanEnd = $filter('date')(data.end, 'dd.MM.yyyy')
        $scope.notify("Added sprint from #{humanStart} to #{humanEnd}", 'info')
      , (reason) ->
        $scope.notify(reason.data.message, 'danger')

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
