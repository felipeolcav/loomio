angular.module('loomioApp').directive 'proposalCollapsed', ->
  scope: {proposal: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/proposal_collapsed/proposal_collapsed.html'
  replace: true
  controller: ($scope, User) ->

    $scope.lastVoteByCurrentUser = (proposal) ->
      proposal.lastVoteByUser(User.current())
