# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Layout/LineLength

require 'slop'

# Menu generator
class MenuGenerator
  # Creates the main menu.
  #
  # @return [Slop::Result] A Slop::Result instance.
  def self.make_main_menu
    Slop.parse(ARGV[0..1]) do |o|
      o.bool 'setup', 'Run the initial setup wizard.'
      o.bool 'login', 'Login with your JIRA credentials.'
      o.bool 'logout', 'Logout current user.'
      o.bool 'config', 'Update configuration.'
      o.bool 'scheduled', 'Manage scheduled issues.'
      o.on '--version', '-v', 'Prints jira-logwork version.' do
        puts "jira-logwork v#{Constants::VERSION}"
        exit
      end
    end
  end

  # Creates the config menu.
  #
  # @return [Slop::Result] A Slop::Result instance.
  def self.make_config_menu
    opts = Slop::Options.new
    opts.banner = "usage: #{$PROGRAM_NAME} config [option] [value]"
    opts.string 'url', 'Set the JIRA Server URL.'
    opts.string 'shift_start', "Set shift start time. Format: HH:mm, e.g. '10:00'."
    opts.string 'shift_end', "Set shift end time. Format: HH:mm, e.g. '18:00'."
    opts.bool 'print', 'Print all your configuration values.'

    Slop::Parser.new(opts).parse(ARGV[1..ARGV.count - 1])
  rescue Slop::MissingArgument => e
    puts e
    exit 1
  end

  # Creates the repeatables menu.
  #
  # @return [Slop::Result] A Slop::Result instance.
  def self.make_scheduled_menu
    opts = Slop::Options.new
    opts.banner = 'usage: scheduled [command] [ISSUE_ID] [options]'
    opts.string 'add', "Add a new scheduled issue. Syntax: 'add [ISSUE_ID] [Options]', e.g. add ABC-13 10:00 2h30m."
    opts.string 'remove', "Remove a scheduled issue from Database. Syntax 'remove [ISSUE_ID]', e.g. remove ABC-13. You can specify the --date option to remove from a specific date."
    opts.bool 'list', 'List scheduled issues.'
    opts.separator 'Options:'
    opts.string '--repeat', 'An integer that indicates the day of the week the issue is repeated: 0: Everyday, 1: Monday - 7: Sunday.'
    opts.string '--date', 'A date the issue will be scheduled in MM/DD/YYYY format.'
    opts.string '--start_time', 'Time in 24h format (optional), e.g. 10:00. '
    opts.string '--duration', 'A duration of the issue (optional), e.g. 30m, 1h30m, etc.'
    Slop::Parser.new(opts).parse(ARGV[1..ARGV.count - 1])
  rescue Slop::MissingArgument => e
    puts e
    exit 1
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Layout/LineLength
