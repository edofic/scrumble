'use strict'

describe 'Directive: projectsList', ->

  # load the directive's module
  beforeEach module 'scrumbleApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<projects-list></projects-list>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the projectsList directive'
