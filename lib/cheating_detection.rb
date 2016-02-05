require 'moss_ruby'
require 'fileutils'

class CheatingDetection

  TEMP_DIR = 'moss_tmp'

  def initialize(user, repo, moss_id = 000000000)
    @user = user
    @repo = repo
    @moss_id = moss_id
  end

  def detect
    pull_details = PullBranchLister.new(@user, @repo).list

    make_tmp_dir

    commands = pull_details.map &command_orgnaizer()

    commands.flatten.each do |command|
      prepared_command = command.call
      `#{prepared_command}` unless prepared_command.empty?
    end

    # Create the MossRuby object
    @moss ||= MossRuby.new(@moss_id) #replace 000000000 with your user id

    # Set options  -- the options will already have these default values
    @moss.options[:max_matches] = 10
    @moss.options[:directory_submission] =  false
    @moss.options[:show_num_matches] = 250
    @moss.options[:experimental_server] =    false
    @moss.options[:comment] = ""
    @moss.options[:language] = "cc"

    # Create a file hash, with the files to be processed
    to_check = MossRuby.empty_file_hash
    #MossRuby.add_file(to_check, "#{TEMP_DIR}/**/*.h")
    MossRuby.add_file(to_check, "#{TEMP_DIR}/**/*.cpp")

    # Get server to process files
    url = @moss.check to_check

    # Get results
    results = @moss.extract_results url

    # Use results
    puts "Got results from #{url}"
    results.each_with_index { |match, i|
        puts "----"
        html = ""
        match.each { |file|
            puts "#{file[:filename]} #{file[:pct]} #{file[:html]}"
            html += file[:html]
        }
        IO.write "result#{1}.html", html
    }
  end

private
  def make_folder_for_branch(user, branch)
    ->(){ FileUtils.mkdir_p("#{TEMP_DIR}/#{user}_#{branch.gsub('/', '_')}") }
  end

  def copy_file(source, dest)
    ->(){ "cp #{source} #{dest}" }
  end

  def extract_source_files(user, branch, dest_folder)
    ->(){
      files = `git ls-tree --full-name --name-only -r #{user}/#{branch} | grep '.h$\\|.cpp$'`.split("\n")
      copy_files = files.map do |file|
        copy_file(file, "#{dest_folder}/#{file}").call
      end
      copy_files.join(" && ")
    }
  end

  def make_tmp_dir
    `mkdir #{TEMP_DIR}`
  end

  def command_orgnaizer
    ->(pull_context){
      [
        make_folder_for_branch(pull_context[0], pull_context[1]),
        ProjectRepoSync::git_checkout("#{pull_context[0]}/#{pull_context[1]}"),
        extract_source_files(pull_context[0], pull_context[1], "#{TEMP_DIR}/#{pull_context[0]}_#{pull_context[1].gsub('/', '_')}")
      ]
    }
  end
end
