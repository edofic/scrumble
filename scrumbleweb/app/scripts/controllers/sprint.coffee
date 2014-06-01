'use strict'

angular.module('scrumbleApp')
  .controller 'SprintCtrl', ($scope, $filter, Sprint, growl) ->

    $scope.dateOptions =
      'starting-day': 1
      'show-weeks': false

    $scope.today = Date.now()
    $scope.addDays = (date, num) ->
      ret = new Date(date)
      ret.setDate(ret.getDate()+num)
      ret.getTime()

    $scope.isScrum = ->
      user = $scope.currentUser
      projectUsers = user.projects[user.activeProject].users
      projectUsers[user.id] && ('ScrumMaster' in projectUsers[user.id].roles)
    $scope.isDeveloper = ->
      user = $scope.currentUser
      projectUsers = user.projects[user.activeProject].users
      projectUsers[user.id] && ('Developer' in projectUsers[user.id].roles)
    $scope.isProduct = ->
      user = $scope.currentUser
      projectUsers = user.projects[user.activeProject].users
      projectUsers[user.id] && ('ProductOwner' in projectUsers[user.id].roles)

    updateFromActiveProject = ->
      user = $scope.currentUser
      if(!user || !user.activeProject)
        return
      $scope.sprints = Sprint.query {projectId: user.activeProject}

      isAdmin = user.role == 'Administrator'
      $scope.canCreateSprint = isAdmin || $scope.isScrum()

    $scope.$watch 'currentUser.activeProject', updateFromActiveProject

    $scope.autoError = {}
    $scope.submitSprint = (sprint, invalid) ->
      if !sprint.id?
        $scope.createSprint(sprint, invalid)
      else
        $scope.updateSprint(sprint, invalid)

    $scope.createSprint = (sprint, invalid) ->
      if (invalid)
        return
      sprintCopy = angular.copy(sprint)
      sprintCopy.start = sprintCopy.start.getTime()
      sprintCopy.end = sprintCopy.end.getTime()
      sprintCopy.$save {projectId: $scope.currentUser.activeProject}, (data) ->
        $scope.sprints.push(data)
        $scope.initNewSprint()
        humanStart = $filter('date')(data.start, 'dd.MM.yyyy')
        humanEnd = $filter('date')(data.end, 'dd.MM.yyyy')
        growl.addSuccessMessage("Added sprint from #{humanStart} to #{humanEnd}")
        $scope.autoError.removeErrors()
      , (reason) ->
        growl.addErrorMessage($scope.backupError(reason.data.message, "An error occured while creating sprint"))
        $scope.autoError.showErrors(reason.data)

    $scope.initNewSprint = () ->
      $scope.sprint = new Sprint()

    $scope.initNewSprint()

    $scope.editSprint = (sprint) ->
      $scope.sprint = angular.copy(sprint)
      $scope.sprint.start = new Date($scope.sprint.start)
      $scope.sprint.end = new Date($scope.sprint.end)

    $scope.updateSprint = (sprint, invalid) ->
      return if (invalid)

      sprintCopy = angular.copy(sprint)
      sprintCopy.start = sprintCopy.start.getTime()
      sprintCopy.end = sprintCopy.end.getTime()
      sprintCopy.$update {projectId: $scope.currentUser.activeProject, sprintId: sprint.id}, (data) ->
        $scope.initNewSprint()
        humanStart = $filter('date')(data.start, 'dd.MM.yyyy')
        humanEnd = $filter('date')(data.end, 'dd.MM.yyyy')
        growl.addSuccessMessage("Sprint changed")
        $scope.autoError.removeErrors()
        $scope.sprints = Sprint.query {projectId: $scope.currentUser.activeProject}
      , (reason) ->
        growl.addErrorMessage($scope.backupError(reason.data.message, "An error occured while changing sprint"))
        $scope.autoError.showErrors(reason.data)


  .directive 'dateLessThan', ->
    require: 'ngModel',
    link: (scope, elem, attrs, ctrl) ->
      validate = ->
        ctrl.$setValidity('dateLessThan', new Date(ctrl.$viewValue) < new Date(attrs.dateLessThan))
      scope.$watch attrs.ngModel, validate
      attrs.$observe 'dateLessThan', validate

  .directive 'dateParseInput', ->
    restrict: 'A'
    require: 'ngModel'
    link: (scope, elem, attrs, ctrl) ->
      ctrl.$parsers.unshift (viewValue) ->
        if(viewValue instanceof Date)
          return viewValue
        splitted = viewValue.split('.')
        convertedDate = splitted[1] + "/" + splitted[0] + "/" + splitted[2]
        return new Date(Date.parse(convertedDate))
