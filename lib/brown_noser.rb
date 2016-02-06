require 'optparse'
autoload :ClientResolver,          File.expand_path(File.dirname(__FILE__)) + '/client_resolver.rb'
autoload :ProjectRepoSync,         File.expand_path(File.dirname(__FILE__)) + '/project_repo_sync.rb'
autoload :ProjectRepoSearcher,     File.expand_path(File.dirname(__FILE__)) + '/project_repo_searcher.rb'
autoload :CheatingDetection,       File.expand_path(File.dirname(__FILE__)) + '/cheating_detection.rb'
autoload :PullBranchLister,        File.expand_path(File.dirname(__FILE__)) + '/pull_branch_lister.rb'
autoload :PullBranchFileExtractor, File.expand_path(File.dirname(__FILE__)) + '/pull_branch_file_extractor.rb'

class BrownNoser
  attr_reader :options

  def initialize
    @options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: pet <USER> <REPO> [options]"

      opts.on('-s', '--sync', 'Sync') { |v| @options[:sync_flag] = true }
      opts.on('-f', '--find QUERY', 'Find') { |v| @options[:query] = v }
      opts.on('-u', '--username USER', 'Github User') { |v| @options[:username] = v }
      opts.on('-p', '--password PASS', 'Github Pass') { |v| @options[:password] = v }
      opts.on('-c', '--cheat MOSSID', 'Moss Userid') { |v| @options[:moss_id] = v }

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
    cheat = @options[:moss_id]
    resolve_client
    if sync
      repo_syncer = ProjectRepoSync.new ARGV[0], ARGV[1]
      repo_syncer.sync_assignment_branches
    elsif find
      searcher = ProjectRepoSearcher.new.search find
    elsif cheat
      puts "CHEAT"
      cheat_detection = CheatingDetection.new(ARGV[0], ARGV[1], {moss_id: cheat}).detect
    end
  end
end
