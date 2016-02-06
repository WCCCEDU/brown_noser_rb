require 'moss_ruby'
require 'fileutils'

class CheatingDetection

  MOSS_LOGGER_CALLBACK = ->(message=""){puts message}
  TEMP_DIR = 'brown_noser_cheat_detection'

  def initialize(user, repo, moss_options={})
    @user = user
    @repo = repo
    @moss_id = moss_options.fetch(:moss_id, 000000000)

    # Create the MossRuby object
    @moss ||= MossRuby.new(@moss_id) #replace 000000000 with your user id

    # Set options  -- the options will already have these default values
    @moss.options[:max_matches]          = moss_options.fetch(:max_matches,          10)
    @moss.options[:directory_submission] = moss_options.fetch(:directory_submission, false)
    @moss.options[:show_num_matches]     = moss_options.fetch(:show_num_matches,     250)
    @moss.options[:experimental_server]  = moss_options.fetch(:experimental_server,  false)
    @moss.options[:comment]              = moss_options.fetch(:comment,              '')
    @moss.options[:language]             = moss_options.fetch(:comment,              'cc')
  end

  def detect
    pull_details = PullBranchLister.new(@user, @repo).list
    extractor = PullBranchFileExtractor.new(TEMP_DIR, pull_details)
    extractor.extract

    # Create a file hash, with the files to be processed
    to_check = MossRuby.empty_file_hash
    files_to_check = Dir.glob("#{TEMP_DIR}/**/*").select { |f| f =~ /\.(h|cpp)$/ }
    MossRuby.add_file(to_check, files_to_check)

    # Get server to process files
    url = @moss.check to_check, MOSS_LOGGER_CALLBACK

    IO.write "brown_noser.html", "<div><h3>Cheat Detection Results</h3><br/><a href='#{url}'>#{url}</a></div>"
    extractor.cleanup

    # Get results
    results = @moss.extract_results url
  end

private
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
