'use strict'

angular.module('scrumbleApp')
  .service 'AutoError', ($rootScope) ->
    ###
    .row, .fake-row
      [ng-model], [fake-ng-model]
    ###

    errorElements = []
    showErrors: (errorPerField, containerElement) ->
      _.each errorElements, (errElem) -> errElem.remove()

      errorElements = _.map errorPerField, (errorMessage, errorField) ->
        fieldInput = containerElement.find "[ng-model$=\"#{errorField}\"], [fake-ng-model$=\"#{errorField}\"]"
        fieldParent = fieldInput.closest '.row, .fake-row'
        return false if fieldParent.length <= 0

        errElem = angular.element "<div class=\"auto-error-message, alert, alert-danger\">#{errorMessage}</div>"
        fieldParent.after errElem
        errElem
