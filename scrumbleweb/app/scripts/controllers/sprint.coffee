'use strict'

angular.module('scrumbleApp')
  .controller 'SprintCtrl', ($scope, $filter) ->
    # is scrum master?
    $scope.canCreateSprint = -> true

    $scope.sprints = [{
      start: 1393662209873
      end: 1396662209873
      velocity: 20
    }
    {
      start: 1396662209873
      end: 1406662209873  # end > start
      velocity: 20        # integer..
    }]

    $scope.dateOptions =
      'starting-day': 1
      'show-weeks': false

    $scope.today = Date.now()

    ###
    TODO:
    $scope.sprints = Sprint.query()

    $scope.createSprint = (sprint, invalid) ->
      if (invalid)
        return
      sprint.$save (data) ->
        $scope.sprints.push(data)
        $scope.initNewSprint()
        humanStart = $filter('date')(data.start, 'dd.MM.yyyy')
        humanEnd = $filter('date')(data.end, 'dd.MM.yyyy')
        $scope.notify("Added sprint from #{humanStart} to #{humanEnd}", 'info')
      , (reason) ->
        $scope.notify(reason.data.message, 'danger')
    ###
    $scope.initNewSprint = () ->
      ###
      TODO:
      $scope.sprint = new Sprint()
      ###
      $scope.sprint = {}

    $scope.initNewSprint()
