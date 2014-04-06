'use strict'

angular.module('scrumbleApp')
  .factory 'Project', ($resource, ApiRoot) ->
    $resource(ApiRoot + '/api/projects/:projectId', {},
      query:
        method: 'GET'
        isArray: true
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
