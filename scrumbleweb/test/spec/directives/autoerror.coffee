'use strict'

describe 'Directive: autoerror', ->

  # load the directive's module
  beforeEach module 'scrumbleApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<autoerror></autoerror>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the autoerror directive'
