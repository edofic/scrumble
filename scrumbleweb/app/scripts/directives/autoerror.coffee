'use strict'

angular.module('scrumbleApp')
  .directive('autoerror', ->
    scope:
      'autoerror': '='
    restrict: 'A'
    link: (scope, element, attrs) ->
      ###
      .row, .fake-row
        [ng-model], [fake-ng-model]
      ###

      errorElements = []
      scope.autoerror.removeErrors = ->
        _.each errorElements, (errElem) -> errElem.remove()
        errorElements.length = 0

      scope.autoerror.showErrors = (errorPerField) ->
        scope.autoerror.removeErrors()

        errorElements = _.map errorPerField, (errorMessage, errorField) ->
          fieldInput = element.find "[ng-model$=\"#{errorField}\"], [fake-ng-model$=\"#{errorField}\"]"
          fieldParent = fieldInput.closest '.row, .fake-row'
          return false if fieldParent.length <= 0

          errElem = angular.element "<div class=\"auto-error-message alert alert-danger\">#{errorMessage}</div>"
          fieldParent.after errElem
          errElem
        errorElements = _.compact errorElements

  )
