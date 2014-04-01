'use strict'

angular.module('scrumbleApp')
  .controller 'LogoutCtrl', ($scope, $location, Auth) ->
    Auth.logout().then ->
      $location.path('/login')
