'use strict'

angular.module('scrumbleApp')
  .controller 'WallCtrl', ($scope, $rootScope, ProjectUser, ProjectPost, ProjectPostComment) ->
    projectId = $rootScope.currentUser.activeProject

    ProjectUser.get projectId: projectId, userId: $rootScope.currentUser.id, (projectUser) ->
      $scope.isScrumMaster = 'ScrumMaster' in projectUser.roles
      $scope.isScrumMaster = no

    $scope.posts = [
      id: 1
      user: 'Post Author'
      userId: 42
      date: new Date().getTime()
      content: 'New post'
      comments: [
        id: 1
        user: 'Comment author'
        userId: 43
        date: new Date().getTime()
        content: 'New comment'
      ]
    ]

    $scope.newPost =
      content: ''

    $scope.newPostSubmit = ->
      $scope.posts.push
        user: $scope.$root.currentUser.firstName + ' ' + $rootScope.currentUser.lastName
        userId: $scope.$root.currentUser.id
        date: new Date().getTime()
        content: $scope.newPost.content
        comments: []

      $scope.newPost.content = ''

    $scope.canRemovePost = (post) ->
      $scope.isScrumMaster or post.userId == $rootScope.currentUser.id

    $scope.removePost = (post) ->
      $scope.posts.splice($scope.posts.indexOf(post), 1)

    $scope.postAddComment = (post) ->
      post.newComment =
        content: ''

    $scope.postAddCommentSubmit = (post) ->
      post.comments.push
        user: $scope.$root.currentUser.firstName + ' ' + $scope.$root.currentUser.lastName
        userId: $scope.$root.currentUser.id
        date: new Date().getTime()
        content: post.newComment.content

      post.newComment = null

    $scope.postAddCommentCancel = (post) ->
      post.newComment = null

    $scope.postCanRemoveComment = (post, comment) ->
      $scope.isScrumMaster or comment.userId == $rootScope.currentUser.id

    $scope.postRemoveComment = (post, comment) ->
      post.comments.splice(post.comments.indexOf(comment), 1)
