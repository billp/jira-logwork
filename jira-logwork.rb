#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.expand_path('.', __dir__), 'lib')

require 'slop'
require 'communicator'
require 'setup_wizard'

class JiraLogwork
  def self.boot()
    parse_main_arguments()
  end

  def self.parse_main_arguments
    # Parse command-line arguments
    begin
      main = Slop.parse do |o|
        o.bool 'setup', 'Run the initial setup wizard.'
        o.bool 'login', 'Login with your JIRA credentials.'
        o.bool 'logout', 'Logout current user.'
        o.bool 'config', 'Update configuration.'
        o.on '--version', '-v', 'Prints jira-logwork version.' do
          puts "jira-logwork v#{Constants::VERSION}"
          exit
        end  
      end
    rescue Slop::Error => ex
      puts ex
      exit 1
    end

    if main[:login]
      if Communicator.instance.logged_in?
        Utilities.log("You are already logged in.", { type: :success})
      else
        Utilities.log("Please enter your login credentials.")
        SetupWizard.new.set_login_credentials
      end
    elsif main[:logout]
      begin
        Communicator.instance.logout
        Utilities.log("Logout success.", { type: :success })
      rescue UserNotLoggedInException => e
        Utilities.log(e, { type: :error })
      end
    elsif main[:config]
      parse_config_arguments
    elsif main[:setup]
      run_setup
    else
      print main
    end
  end

  def self.run_setup
    SetupWizard.new.run
  end

  def self.parse_config_arguments
    opts = Slop::Options.new
    opts.banner = "usage: #{$0} config [option] [value]"
    opts.string "url", "Set the JIRA Server URL."
    opts.string "shift_start", "Set shift start time. Format: HH:mm, e.g. '10:00'."
    opts.string "shift_end", "Set shift end time. Format: HH:mm, e.g. '18:00'."
    opts.bool "print", "Print all your configuration values."

    begin
      config = Slop::Parser.new(opts).parse(ARGV[1..ARGV.count-1])
    rescue Slop::MissingArgument => e
      puts e
      return
    end 

    if !config[:url].nil? 
      begin
        ConfigurationManager.instance.update_jira_server_url(config[:url])
      rescue InvalidURLException
        Utilities.log("Invalid JIRA server URL.", { type: :error })
      end
    elsif !config[:shift_start].nil?
      begin
        ConfigurationManager.instance.update_shift_start(config[:shift_start])
      rescue InvalidTimeException
        Utilities.log("Invalid starttime format.", { type: :error })
      end
    elsif !config[:shift_end].nil?
      begin
        ConfigurationManager.instance.update_shift_end(config[:shift_end])
        puts ConfigurationManager.instance.shift_duration
      rescue InvalidTimeException
        Utilities.log("Invalid end time format.", { type: :error })
      end
    elsif config[:print]
      puts "url = #{ConfigurationManager.instance.print_value(:url)}"
      puts "shift_start = #{ConfigurationManager.instance.print_value(:shift_start)}"
      puts "shift_end = #{ConfigurationManager.instance.print_value(:shift_end)}"
    else
      print config
    end
  end
end

# Start application
JiraLogwork.boot()