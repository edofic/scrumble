'use strict'

angular.module('scrumbleApp')
  .controller 'UsersCtrl', ($scope, User, UserPassword) ->
    $scope.users = User.query()
    $scope.userRoles =
      'RegularUser': 'Regular user'
      'Administrator': 'Administrator'

    $scope.initNewUser = ->
      $scope.user = new User()
      $scope.user.role = 'RegularUser'

    $scope.initNewUser()

    $scope.createUser = (user, invalid) ->
      if (invalid)
        return

      $scope.userPassword = new UserPassword()
      $scope.userPassword.newPassword = $scope.user.password

      $scope.user.$save (data) ->
        $scope.userPassword.$save(userId: data.id)

        $scope.users.push(data)
        $scope.initNewUser()
        $scope.error = ''
      , (reason) ->
        $scope.error = 'User cannot be saved.'
        console.log('Error occured: ', reason)

  .directive 'sameAs', ->
    require: 'ngModel',
    link: (scope, elem, attrs, ctrl) ->
      ctrl.$parsers.unshift (viewValue) ->
        if (viewValue == attrs.sameAs)
          ctrl.$setValidity("sameAs", true)
          return viewValue
        else
          ctrl.$setValidity("sameAs", false)
          return
