'use strict'

angular.module('scrumbleApp')
  .controller 'ProjectsCtrl', ($scope, Project, User) ->
    $scope.needsAdmin('You don\'t have permission to manage projects')

    User.query((users) ->
      $scope.allUsernames = $.map users, (user) ->
        user.username
    )

    $scope.userProjectRoles =
      productOwner: 'Product'
      scrumMaster: 'Scrum'
      teamMember: 'Team'

    $scope.projects = Project.query()
    ### Wanted from API:
    [{
        name: 'TPO14_2014'
        users: [
          {username: 'lz', productOwner: false, scrumMaster: false, teamMember: true}
          {username: 'lj', productOwner: false, scrumMaster: false, teamMember: true}
          {username: 'ab', productOwner: false, scrumMaster: true, teamMember: true}
          {username: 'br', productOwner: false, scrumMaster: false, teamMember: true}
          {username: 'mh', productOwner: true, scrumMaster: false, teamMember: false}
        ]
    }]
    ###

    $scope.createProject = (project, invalid) ->
      if (invalid)
        return
      project.$save (data) ->
        $scope.projects.push(data)
        $scope.initNewProject()
        $scope.notify("Added project #{data.name}", 'info')
      , (reason) ->
        $scope.notify(reason.data.message, 'danger')

    $scope.initNewProject = () ->
      $scope.project = new Project()
      $scope.project.users = [{}, {}, {}, {}]

    $scope.initNewProject()
