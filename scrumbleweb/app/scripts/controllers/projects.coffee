'use strict'

angular.module('scrumbleApp')
  .controller 'ProjectsCtrl', ($scope) ->
    $scope.needsAdmin('You don\'t have permission to manage projects')

    $scope.allUsernames = ['lj', 'lz', 'ab', 'br', 'mh', 'aaaa', 'bbbb', 'bz', 'br', 'bh'];

    $scope.userProjectRoles =
      productOwner: 'Product'
      scrumMaster: 'Scrum'
      teamMember: 'Team'

    $scope.projects = [
      {
        name: 'TPO14_2014'
        users: [
          {username: 'lz', productOwner: false, scrumMaster: false, teamMember: true}
          {username: 'lj', productOwner: false, scrumMaster: false, teamMember: true}
          {username: 'ab', productOwner: false, scrumMaster: true, teamMember: true}
          {username: 'br', productOwner: false, scrumMaster: false, teamMember: true}
          {username: 'mh', productOwner: true, scrumMaster: false, teamMember: false}
        ]
      }
      {
        name: 'TPO15_2014'
        users: [
          {username: 'bz', productOwner: false, scrumMaster: false, teamMember: true}
          {username: 'bj', productOwner: false, scrumMaster: false, teamMember: true}
          {username: 'bb', productOwner: false, scrumMaster: true, teamMember: true}
          {username: 'br', productOwner: false, scrumMaster: false, teamMember: true}
          {username: 'bh', productOwner: true, scrumMaster: false, teamMember: false}
        ]
      }
    ]

    ###
    TODO:
    $scope.projects = Project.query()

    $scope.createProject = (project, invalid) ->
      if (invalid)
        return
      project.$save (data) ->
        $scope.projects.push(data)
        $scope.initNewProject()
        $scope.notify("Added project #{data.name}", 'info')
      , (reason) ->
        $scope.notify(reason.data.message, 'danger')
    ###

    $scope.initNewProject = () ->
      ###
      TODO:
      $scope.project = new Project()
      $scope.project.users = [{}, {}, {}, {}]
      ###
      $scope.project = {users: [{}, {}, {}, {}]}

    $scope.initNewProject()
