require 'moss_ruby'
require 'fileutils'

class CheatingDetection

  TEMP_DIR = 'brown_noser_cheat_detection'

  def initialize(user, repo, moss_id = 000000000)
    @user = user
    @repo = repo
    @moss_id = moss_id
  end

  def detect
    pull_details = PullBranchLister.new(@user, @repo).list

    recreate_tmp_dir

    commands = pull_details.map &command_orgnaizer()

    commands.flatten.each do |command|
      prepared_command = command.call
      puts prepared_command unless prepared_command.empty?
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

    IO.write "brown_noser.html", "<div><h3>Cheat Detection Results</h3><br/><a href='#{url}'>#{url}</a></div>"
    FileUtils.rm_rf TEMP_DIR

    # Get results
    results = @moss.extract_results url
  end

private
  def make_folder_for_branch(user, branch)
    ->(){ FileUtils.mkdir_p("#{TEMP_DIR}/#{user}_#{branch}") }
  end

  def copy_file(source, dest)
    ->(){ "cp \"#{source}\" \"#{dest}\"" }
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

  def recreate_tmp_dir
    FileUtils.rm_rf TEMP_DIR
    FileUtils.mkdir TEMP_DIR
  end

  def command_orgnaizer
    ->(pull_context){
      [
        make_folder_for_branch(pull_context[0], pull_context[1]),
        ProjectRepoSync::git_checkout("#{pull_context[0]}/#{pull_context[1]}"),
        extract_source_files(pull_context[0], pull_context[1], "#{TEMP_DIR}/#{pull_context[0]}_#{pull_context[1]}")
      ]
    }
  end

  def extract_results
    results.each_with_index { |match, i|
      match.each { |file|
        report_match = <<-HTML
          <div class="match">
            <h3>#{file[:filename]}</h3>
            <h4>#{file[:pct]}</h4>
            <h4>#{file[:url]}</h4>
            <h4>#{file[:part_url]}</h4>
            <div class="code">#{file[:html]}</div>
          </div>
        HTML
        result_html += report_match
      }
      result_html += "<hr/>"
    }
    IO.write "cheat_report.html", result_html
  end
end
