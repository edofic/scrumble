'use strict'

angular.module('scrumbleApp')
  .service 'bbox', ($rootScope) ->
    prompt: (msg, cb) ->
      _.defer ->
        bootbox.prompt msg, (result) ->
          $rootScope.$apply ->
            cb(result)

    confirm: (msg, cb) ->
      _.defer ->
        bootbox.confirm msg, (result) ->
          $rootScope.$apply ->
            cb(result)
