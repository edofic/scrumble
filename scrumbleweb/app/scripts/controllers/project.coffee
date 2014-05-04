'use strict'

angular.module('scrumbleApp')
  .controller 'ProjectCtrl', ($scope, $routeParams, User, Project, ProjectUser, Auth, growl, bbox) ->
    $scope.needsAdmin('You don\'t have permission to manage projects')

    $scope.canEdit = -> $scope.isAdmin()

    $scope.projectHasRole =
      'ProductOwner': false
      'ScrumMaster': false

    $scope.load = ->
      $scope.allUsers = User.query()
      $scope.project = Project.get projectId: $routeParams.projectId
      $scope.users = ProjectUser.query projectId: $routeParams.projectId, (users) ->
        $scope.allUsers.$promise.then (allUsers) ->
          allUsersMap = _.zipObject(_.map(allUsers, (u) -> [u.id, u]))
          _.map users, (user) ->
            user.user = allUsersMap[user.user]

          $scope.projectHasRole['ScrumMaster'] = _.find(users, {roles: ['ScrumMaster']})?
          $scope.projectHasRole['ProductOwner'] = _.find(users, {roles: ['ProductOwner']})?

        , (reason) ->
          growl.addErrorMessage($scope.backupError(reason.data.message, "An error occured while getting users"))
      , (reason) ->
        growl.addErrorMessage($scope.backupError(reason.data.message, "An error occured while getting users"))

    $scope.rename = ->
      bbox.prompt 'New project name:', (newName) ->
        return if not newName

        tempProject = angular.copy($scope.project)
        tempProject.name = newName

        tempProject.$update projectId: tempProject.id, (data) ->
          $scope.load()

          growl.addSuccessMessage("Project #{data.name} has been updated")
        , (reason) ->
          growl.addErrorMessage($scope.backupError(reason.data.message || reason.data.name, "An error occured while renaming project"))


    $scope.editUser = (user) ->
      user.$copy = angular.copy(user)
      trueArr = _.map _.range(user.roles.length), -> true
      user.roles = _.zipObject(user.roles, trueArr)
      user.editing = yes

    $scope.cancelEditUser = (user) ->
      angular.extend(user, user.$copy)
      user.editing = no

    $scope.saveUser = (user) ->
      u = new ProjectUser
      u.user = user.user.id
      u.roles = _.keys(_.pick(user.roles, (value) -> value ))
      u.project = $scope.project.id # WHY???

      u.$update projectId: $scope.project.id, userId: user.user.id, (res) ->
        $scope.initNewUser()
        $scope.load()
        Auth.loadCurrentUser() if u.user == $scope.currentUser.id
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
      u.roles = _.keys(_.pick($scope.newUser.roles, (value) -> value ))
      u.project = $scope.project.id # WHY???

      u.$save projectId: $scope.project.id, (res) ->
        $scope.initNewUser()
        $scope.load()
        $scope.autoErrorAddUser.removeErrors()
      , (reason) ->
        growl.addErrorMessage($scope.backupError(reason.data.message || reason.data.error, "An error occured while adding user"))
        $scope.autoErrorAddUser.showErrors(reason.data)

    $scope.initNewUser = ->
      $scope.newUser =
        roles: {'Developer': true}


    $scope.rolesToRules = (user, changedRole) ->
      if user.roles['ScrumMaster'] && user.roles['ProductOwner']
        if changedRole == 'ScrumMaster'
          user.roles['ProductOwner'] = false
        else
          user.roles['ScrumMaster'] = false

    $scope.projectRoleAllowed = (user, changeableRole) ->
      user.roles[changeableRole] || !$scope.projectHasRole[changeableRole]


    $scope.load()
    $scope.initNewUser()
