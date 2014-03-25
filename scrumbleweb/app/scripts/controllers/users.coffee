'use strict'

angular.module('scrumbleApp')
  .controller 'UsersCtrl', ($scope, User) ->
    $scope.users = User.query()
