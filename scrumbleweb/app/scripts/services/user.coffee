'use strict'

angular.module('scrumbleApp')
  .factory 'User', ($resource) ->
    $resource('http://scrumble.apiary.io/users/:userId', {},
      query:
        method: 'GET'
        isArray: true
    )
