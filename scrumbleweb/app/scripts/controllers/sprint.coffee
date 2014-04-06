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
