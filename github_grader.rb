require 'octokit'
require 'ap'

LOGIN = ENV['GRADER_LOGIN']
PASSWORD = ENV['GRADER_PASSWORD']
puts LOGIN

client = Octokit::Client.new(:login => LOGIN, :password => PASSWORD)

USER = 'WCCCEDU'
REPO = 'CPT-180-27-Assignment-1-Coding'

PULL_EXTRACTOR = ->(pull){ pull.head.label }
GIT_COMMAND_EXTRACTOR = ->(pull_info){ pull_info.split(':') }
GIT_COMMAND_ORGANIZAER = ->(pull_context){
  [
    git_checkout( pull_context[1] ),
    git_pull( prep_repo(pull_context[0], REPO).call, pull_context[1] )
  ]
}

def prep_repo(user, repo)
  ->(){ "https://github.com/#{user}/#{repo}.git" }
end

def git_checkout(branch)
  ->(){ "git checkout -b #{branch} master" }
end

def git_pull(repo_url, branch)
  ->(){ "git pull #{repo_url} #{branch}" }
end

SOURCE_REPO = "#{USER}/#{REPO}"

puts SOURCE_REPO
pulls = client.pulls SOURCE_REPO
pull_details = pulls.map(&PULL_EXTRACTOR).map(&GIT_COMMAND_EXTRACTOR)

git_commands = pull_details.map &GIT_COMMAND_ORGANIZAER
git_commands.flatten.each do |command|
  prepared_command = command.call
  puts "Spawning #{prepared_command}"
  spawn command
end
