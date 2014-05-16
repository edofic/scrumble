'use strict'

angular.module('scrumbleApp')
  .controller 'UserCtrl', ($scope, $routeParams, $location, User, UserPassword, growl) ->

    $scope.user = User.get userId: $routeParams.userId
    $scope.userRoles =
      'RegularUser': 'Regular user'
      'Administrator': 'Administrator'

    $scope.autoError = {}
    $scope.updateUser = (user, invalid) ->
      if (invalid)
        return

      $scope.user.$update {userId: user.id}, (data) ->
        growl.addSuccessMessage("Updated user")
        $scope.autoError.removeErrors()
      , (reason) ->
        growl.addErrorMessage($scope.backupError(reason.data.message, "An error occured while saving user"))
        $scope.autoError.showErrors(reason.data)

    $scope.updatePass = (user, invalid) ->
      return if (invalid)

      $scope.userPassword = new UserPassword()
      $scope.userPassword.newPassword = $scope.user.password
      $scope.userPassword.$save userId: user.id, (data) ->
        growl.addSuccessMessage("Password changed")
        $scope.autoError.removeErrors()
        delete $scope.user.password
        delete $scope.user.password2
      , (reason) ->
        growl.addErrorMessage($scope.backupError(reason.data.message, "An error occured while changing password"))
        $scope.autoError.showErrors(reason.data)

    $scope.deleteUser = (user) ->
      $scope.user.$delete {userId: user.id}, (data) ->
        growl.addSuccessMessage("User removed")
        $location.url('/')
      , (reason) ->
        growl.addErrorMessage($scope.backupError(reason.data.message, "An error occured while removing user"))
