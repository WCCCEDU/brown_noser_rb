require 'optparse'
autoload :ClientResolver, File.expand_path(File.dirname(__FILE__)) + '/lib/client_resolver.rb'
autoload :ProjectRepoSync, File.expand_path(File.dirname(__FILE__)) + '/lib/project_repo_sync.rb'
autoload :ProjectRepoSearcher, File.expand_path(File.dirname(__FILE__)) + '/lib/project_repo_searcher.rb'

class TeachersPet
  attr_reader :options

  def initialize
    @options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: pet <USER> <REPO> [options]"

      opts.on('-s', '--sync', 'Sync') { |v| @options[:sync_flag] = true }
      opts.on('-f', '--find QUERY', 'Find') { |v| @options[:query] = v }
      opts.on('-u', '--username USER', 'Source host') { |v| @options[:username] = v }
      opts.on('-p', '--password PASS', 'Source port') { |v| @options[:password] = v }

    end.parse!
  end

  def resolve_client
    user = @options[:username]
    pass = @options[:password]
    if user && pass
      ClientResolver.configure(user, pass)
    end
  end

  def run
    sync = @options[:sync_flag]
    find = @options[:query]
    resolve_client
    if sync
      repo_syncer = ProjectRepoSync.new ARGV[0], ARGV[1]
      repo_syncer.sync_assignment_branches
    elsif find
      searcher = ProjectRepoSearcher.new.search find
    end
  end
end

pet = TeachersPet.new
pet.run
