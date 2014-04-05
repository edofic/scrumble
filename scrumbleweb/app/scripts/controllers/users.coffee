'use strict'

angular.module('scrumbleApp')
  .controller 'UsersCtrl', ($scope, User, UserPassword) ->
    $scope.needsAdmin('You don\'t have permission to manage users')

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
        $scope.notify("Added user #{data.username}" , 'info')
      , (reason) ->
        $scope.notify(reason.data.message, 'danger')

  .directive 'sameAs', ->
    require: 'ngModel',
    link: (scope, elem, attrs, ctrl) ->
      validate = ->
        ctrl.$setValidity('sameAs', ctrl.$viewValue == attrs.sameAs)
      scope.$watch attrs.ngModel, validate
      attrs.$observe 'sameAs', validate
