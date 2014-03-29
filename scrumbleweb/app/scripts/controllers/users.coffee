'use strict'

angular.module('scrumbleApp')
  .controller 'UsersCtrl', ($scope, User) ->
    $scope.users = User.query()
    $scope.userRoles = ['USER', 'ADMIN']

    $scope.initNewUser = () ->
      $scope.user =
        role: $scope.userRoles[0]

    $scope.initNewUser()

    $scope.createUser = (user) ->
      u = new User()
      u.$save(user,
        (data) ->
          $scope.users.push(data);
        (reason) ->
          console.log('Error occured: ', reason);
      )
