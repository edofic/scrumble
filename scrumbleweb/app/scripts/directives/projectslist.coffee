'use strict'

angular.module('scrumbleApp')
  .directive 'projectslist', ->
    templateUrl: 'views/directives/projectslist.html'
    restrict: 'E'
    scope:
      projects: '='
      userProjectRoles: '='
      canActivate: '='
    replace: true
