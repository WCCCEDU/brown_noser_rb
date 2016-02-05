class ProjectRepoSync
  attr_reader :user, :repo

  def self.git_checkout(branch)
    ->(){ "git checkout #{branch}" }
  end

  def initialize(user, repo)
    @client = ClientResolver.client
    @user = user
    @repo = repo
  end

  def sync_assignment_branches
    pull_details = PullBranchLister.new(@user, @repo).list

    %x(git checkout -f master | git branch | grep -v "^..master$" | sed 's/^[ *]*//' | sed 's/^/git branch -D /' | bash)

    git_commands = pull_details.map &git_command_orgnaizer()
    git_commands.flatten.each do |command|
      prepared_command = command.call
      puts "EXEC #{prepared_command}" if @logging
      `#{prepared_command}`
      puts "\n" if @logging
    end
  end

private
  def prep_repo(user, repo)
    ->(){ "https://github.com/#{user}/#{repo}.git" }
  end

  def git_checkout_new(user, branch)
    ->(){ "git checkout -B #{user}/#{branch} master" }
  end

  def git_pull(repo_url, branch)
    ->(){ "git pull #{repo_url} #{branch}" }
  end

  def git_command_orgnaizer
    ->(pull_context){
      [
        git_checkout_new( pull_context[0], pull_context[1] ),
        git_pull( prep_repo(pull_context[0], @repo).call, pull_context[1] ),
        ProjectRepoSync::git_checkout( 'master' )
      ]
    }
  end
end
