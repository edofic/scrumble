'use strict'

describe 'Controller: WallCtrl', ->

  # load the controller's module
  beforeEach module 'scrumbleApp'

  WallCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    WallCtrl = $controller 'WallCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
