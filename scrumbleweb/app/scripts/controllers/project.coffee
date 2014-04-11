'use strict'

angular.module('scrumbleApp')
  .controller 'ProjectCtrl', ($scope, $routeParams, User, Project, ProjectUser, growl, bbox) ->
    $scope.needsAdmin('You don\'t have permission to manage projects')

    $scope.canEdit = -> $scope.isAdmin()

    $scope.load = ->
      $scope.allUsers = User.query()
      $scope.project = Project.get projectId: $routeParams.projectId
      $scope.users = ProjectUser.query projectId: $routeParams.projectId, (users) ->
        $scope.allUsers.$promise.then (allUsers) ->
          allUsersMap = _.zipObject(_.map(allUsers, (u) -> [u.id, u]))
          _.map users, (user) ->
            user.user = allUsersMap[user.user]
        , (reason) ->
          growl.addErrorMessage($scope.backupError(reason.data.message, "An error occured while getting users"))
      , (reason) ->
        growl.addErrorMessage($scope.backupError(reason.data.message, "An error occured while getting users"))

    $scope.rename = ->
      bbox.prompt 'New project name:', (newName) ->
        return if not newName

        tempProject = anuglar.copy($scope.project)
        tempProject.name = newName

        tempProject.$update projectId: tempProject.id, (data) ->
          $scope.load()

          growl.addSuccessMessage("Project #{data.name} has been updated")
        , (reason) ->
          growl.addErrorMessage($scope.backupError(reason.data.message || reason.data.name, "An error occured while renaming project"))

    $scope.editUser = (user) ->
      user.$copy = angular.copy(user)
      user.editing = yes

    $scope.cancelEditUser = (user) ->
      angular.extend(user, user.$copy)
      user.editing = no

    $scope.saveUser = (user) ->
      u = new ProjectUser
      u.user = user.user.id
      u.role = user.role
      u.project = $scope.project.id # WHY???

      u.$update projectId: $scope.project.id, userId: user.user.id, (res) ->
        $scope.initNewUser()
        $scope.load()
      , (reason) ->
        growl.addErrorMessage($scope.backupError(reason.data.message, "An error occured while saving user"))

    $scope.removeUser = (user) ->
      bbox.confirm "Are you sure you want to remove user #{$scope.formatUser(user.user)} from project?", (ok) ->
        if ok?
          user.$delete projectId: $scope.project.id, userId: user.user.id, (res) ->
            $scope.load()
          , (reason) ->
            growl.addErrorMessage($scope.backupError(reason.data.message, "An error occured while removing user"))

    $scope.autoErrorAddUser = {}
    $scope.addUser = (invalid) ->
      if (invalid)
        return
      u = new ProjectUser
      u.user = $scope.newUser.user.id
      u.role = $scope.newUser.role
      u.project = $scope.project.id # WHY???

      u.$save projectId: $scope.project.id, (res) ->
        $scope.initNewUser()
        $scope.load()
        $scope.autoErrorAddUser.removeErrors()
      , (reason) ->
        growl.addErrorMessage($scope.backupError(reason.data.message, "An error occured while adding user"))
        $scope.autoErrorAddUser.showErrors(reason.data)

    $scope.initNewUser = ->
      $scope.newUser =
        role: 'Developer'

    $scope.load()
    $scope.initNewUser()
