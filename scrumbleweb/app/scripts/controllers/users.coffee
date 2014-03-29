'use strict'

angular.module('scrumbleApp')
  .controller 'UsersCtrl', ($scope, User) ->
    $scope.users = User.query()
    $scope.userRoles = ['USER', 'ADMIN']

    $scope.initNewUser = () ->
      $scope.user =
        role: $scope.userRoles[0]

    $scope.initNewUser()

    $scope.createUser = (user, invalid) ->
      if (invalid)
        return
      u = new User()
      u.$save(user,
        (data) ->
          $scope.users.push(data)
          $scope.initNewUser()
        (reason) ->
          console.log('Error occured: ', reason)
      )

  .directive 'sameAs', () ->
    require: 'ngModel',
    link: (scope, elem, attrs, ctrl) ->
      ctrl.$parsers.unshift (viewValue) ->
        if (viewValue == attrs.sameAs)
          ctrl.$setValidity("sameAs", true)
          return viewValue
        else
          ctrl.$setValidity("sameAs", false)
          return
