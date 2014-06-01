'use strict'

angular.module('scrumbleApp')
  .controller 'WallCtrl', ($scope, $rootScope, ProjectUser, ProjectPost, ProjectPostComment, bbox) ->
    projectId = $rootScope.currentUser.activeProject

    ProjectUser.get projectId: projectId, userId: $rootScope.currentUser.id, (projectUser) ->
      $scope.isScrumMaster = 'ScrumMaster' in projectUser.roles

    $scope.posts = []

    $scope.load = ->
      ProjectPost.query projectId: projectId, (posts) ->
        $scope.posts = _.sortBy(posts, (x) -> x.date)
        $scope.posts.reverse()

    $scope.load()

    $scope.newPost =
      content: ''

    $scope.newPostSubmit = ->
      newPost = new ProjectPost()
      newPost.content = $scope.newPost.content
      newPost.$save projectId: projectId, ->
        $scope.newPost.content = ''
        $scope.load()

    $scope.canRemovePost = (post) ->
      $scope.isScrumMaster or post.userId == $rootScope.currentUser.id

    $scope.removePost = (post) ->
      bbox.confirm "Are you sure you want to delete this post?", (ok) ->
        if ok?
          post.$delete projectId: projectId, postId: post.id, $scope.load

    $scope.postAddComment = (post) ->
      post.newComment =
        content: ''

    $scope.postAddCommentSubmit = (post) ->
      newComment = new ProjectPostComment()
      newComment.content = post.newComment.content
      newComment.$save projectId: projectId, postId: post.id, ->
        post.newComment = null
        $scope.load()

    $scope.postAddCommentCancel = (post) ->
      post.newComment = null

    $scope.postCanRemoveComment = (post, comment) ->
      $scope.isScrumMaster or comment.userId == $rootScope.currentUser.id

    $scope.postRemoveComment = (post, comment) ->
      bbox.confirm "Are you sure you want to delete this comment?", (ok) ->
        if ok?
          ProjectPostComment.delete projectId: projectId, postId: post.id, commentId: comment.id, $scope.load
