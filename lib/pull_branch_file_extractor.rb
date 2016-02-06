class PullBranchFileExtractor
  def initialize(temp_dir, pull_details)
    @temp_dir = temp_dir
    @pull_details = pull_details
  end

  def extract
    clean_tmp_dir
    create_tmp_dir

    commands = @pull_details.map &command_orgnaizer()

    commands.flatten.each do |command|
      prepared_command = command.call
      puts prepared_command unless prepared_command.empty?
      `#{prepared_command}` unless prepared_command.empty?
    end
  end

  def cleanup
    clean_tmp_dir
  end

private

  def create_tmp_dir
    FileUtils.mkdir @temp_dir
  end

  def clean_tmp_dir
    FileUtils.rm_rf @temp_dir
  end

  def make_folder_for_branch(user, branch)
    ->(){ FileUtils.mkdir_p("#{@temp_dir}/#{user}_#{branch}") }
  end

  def copy_file(source, dest)
    ->(){ "cp \"#{source}\" \"#{dest}\"" }
  end

  def extract_source_files(user, branch, dest_folder)
    ->(){
      files = `git ls-tree --full-name --name-only -r #{user}/#{branch} | grep '\.h$\\|\.cpp$'`.split("\n")
      copy_files = files.map do |file|
        copy_file(file, "#{dest_folder}/#{file}").call
      end
      copy_files.join(" && ")
    }
  end

  def command_orgnaizer
    ->(pull_context){
      [
        make_folder_for_branch(pull_context[0], pull_context[1]),
        ProjectRepoSync::git_checkout("#{pull_context[0]}/#{pull_context[1]}"),
        extract_source_files(pull_context[0], pull_context[1], "#{@temp_dir}/#{pull_context[0]}_#{pull_context[1]}")
      ]
    }
  end
end
