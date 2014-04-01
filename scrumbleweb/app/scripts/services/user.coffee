'use strict'

angular.module('scrumbleApp')
  .factory 'User', ($resource, ApiRoot) ->
    $resource(ApiRoot + '/api/users/:userId', {},
      query:
        method: 'GET'
        isArray: true
    )

  .factory 'UserPassword', ($resource, ApiRoot) ->
    $resource(ApiRoot + '/api/users/:userId/password', {})
