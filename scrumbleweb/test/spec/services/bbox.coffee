'use strict'

describe 'Service: Bbox', ->

  # load the service's module
  beforeEach module 'scrumbleApp'

  # instantiate service
  Bbox = {}
  beforeEach inject (_Bbox_) ->
    Bbox = _Bbox_

  it 'should do something', ->
    expect(!!Bbox).toBe true
