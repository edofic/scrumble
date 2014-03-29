'use strict'

angular.module('scrumbleApp')
  .controller 'ProjectCtrl', ($scope) ->
    $scope.project =
      name: 'TPO14_2014'
      sprint: 1
      sprints: 4
      ends: 1396046667143
