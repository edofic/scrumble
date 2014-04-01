'use strict'

describe 'Service: ApiRoot', ->

  # load the service's module
  beforeEach module 'scrumbleApp'

  # instantiate service
  ApiRoot = {}
  beforeEach inject (_ApiRoot_) ->
    ApiRoot = _ApiRoot_

  it 'should do something', ->
    expect(!!ApiRoot).toBe true
