'use strict'

angular.module('scrumbleApp')
  .factory 'Project', ($resource, ApiRoot) ->
    $resource(ApiRoot + '/api/projects/:projectId', {},
      query:
        method: 'GET'
        isArray: true
      update:
        method: 'PUT'
    )
  .factory 'ProjectUser', ($resource, ApiRoot) ->
    $resource(ApiRoot + '/api/projects/:projectId/users/:userId', {},
      query:
        method: 'GET'
        isArray: true
      update:
        method: 'PUT'
    )
  .factory 'Sprint', ($resource, ApiRoot) ->
    $resource(ApiRoot + '/api/projects/:projectId/sprints', {},
      query:
        method: 'GET'
        isArray: true
    )
  .factory 'Story', ($resource, ApiRoot) ->
    $resource(ApiRoot + '/api/projects/:projectId/stories', {},
      query:
        method: 'GET'
        isArray: true
    )
