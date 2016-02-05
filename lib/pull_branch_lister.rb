class PullBranchLister

  PULL_EXTRACTOR = ->(pull){ pull.head.label }
  GIT_COMMAND_EXTRACTOR = ->(pull_info){ pull_info.split(':') }

  def initialize(user, repo)
    @client = ClientResolver.client
    @user = user
    @repo = repo
  end

  def list
    pulls = @client.pulls "#{@user}/#{@repo}"
    pulls.map(&PULL_EXTRACTOR).map(&GIT_COMMAND_EXTRACTOR)
  end
end
