'use strict'

angular.module('scrumbleApp')
  .factory 'richQuery', ($q) ->
    (Resource, fn) ->
      originalQuery = Resource.query

      Resource.query = (args, cb) ->
        defer = $q.defer()

        res = originalQuery args, (data) ->
          if data.length
            res.$resolved = no

            fn data, ->
              cb(data)
              res.$resolved = yes
              defer.resolve(data)

          else
            cb(data)
            defer.resolve(data)

        res.$promise = defer.promise

        res

  .directive('onChange', ->
    (scope, elm, attrs) ->
      elm.on 'change', ->
        # we need timeout for angular to update ng-model
        setTimeout ->
          scope.$apply ->
            scope.$eval(attrs.onChange)
        , 0
  )
