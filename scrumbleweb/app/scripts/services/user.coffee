'use strict'

angular.module('scrumbleApp')
  .factory 'User', ($resource) ->
    $resource('http://scrumble.lukazakrajsek.com/api/users/:userId', {},
      query:
        method: 'GET'
        isArray: true
    )

  .factory 'UserPassword', ($resource) ->
    $resource('http://scrumble.lukazakrajsek.com/api/users/:userId/password', {})
