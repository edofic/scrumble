'use strict'

angular.module('scrumbleApp')
  .factory 'Project', ($resource, ApiRoot) ->
    $resource(ApiRoot + '/api/projects/:projectId', {},
      query:
        method: 'GET'
        isArray: true
      update:
        method: 'PUT'
    )
  .factory 'ProjectUser', ($resource, ApiRoot) ->
    $resource(ApiRoot + '/api/projects/:projectId/users/:userId', {},
      query:
        method: 'GET'
        isArray: true
      update:
        method: 'PUT'
    )
  .factory 'Sprint', ($resource, ApiRoot) ->
    $resource(ApiRoot + '/api/projects/:projectId/sprints/:sprintId', {},
      query:
        method: 'GET'
        isArray: true,
        interceptor:
          response: (data) ->
            data.resource.sort (a, b) ->
              a.start - b.start

            number = 1

            _.each data.resource, (x) ->
              x.number = number
              x.current = no
              x.next = no

              number += 1

            now = new Date()

            currentIdx = _.findIndex data.resource, (x) ->
              x.start < now and now < x.end

            if currentIdx != -1
              data.resource[currentIdx].current = yes

              if data.resource[currentIdx + 1]
                data.resource[currentIdx + 1].next = yes

            data.resource
    )

  .factory 'Story', ($resource, $q, richQuery, ApiRoot, Sprint) ->
    Story = $resource(ApiRoot + '/api/projects/:projectId/stories/:storyId', {},
      query:
        method: 'GET'
        isArray: true
      update:
        method: 'PUT'
    )

    richQuery Story, (stories, cb) ->
      projectId = stories[0].project

      Sprint.query projectId: projectId, (sprints) ->
        sprintsMap = _.indexBy sprints, 'id'

        _.each stories, (x) ->
          x.sprint = sprintsMap[x.sprint]

        cb()

    Story

  .factory 'SprintStory', ($resource, ApiRoot) ->
    $resource(ApiRoot + '/api/projects/:projectId/sprints/:sprintId/stories/:storyId', {},
      query:
        method: 'GET'
        isArray: true
      update:
        method: 'PUT'
    )
  .factory 'Task', ($resource, ApiRoot) ->
    $resource(ApiRoot + '/api/projects/:projectId/sprints/:sprintId/stories/:storyId/tasks/:taskId', {},
      query:
        method: 'GET'
        isArray: true
      update:
        method: 'PUT'
    )

