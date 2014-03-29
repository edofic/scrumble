'use strict'

angular.module('scrumbleApp')
  .controller 'MeetingsCtrl', ($scope) ->
    inputNames = ['Work done', 'Work plan', 'Issues']
    $scope.inputObjs = $.map inputNames, (name) ->
      name: name
      value: ''
