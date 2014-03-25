'use strict';

angular.module('scrumbleFrontendApp')
  .controller('MainCtrl', function ($scope) {
    $scope.awesomeThings = [
      'HTML5 Boilerplate',
      'AngularJS',
      'Karma'
    ];
  })
  .controller('MeetingCtrl', function ($scope) {
    var inputNames = ['Work done', 'Work plan', 'Issues'];
    $scope.inputObjs = $.map(inputNames, function(name){
        return {name: name, value: ''};
    });
  })
;
