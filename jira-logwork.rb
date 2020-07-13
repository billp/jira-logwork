#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH << File.join(File.expand_path('.', __dir__), 'lib')

require 'communication/session_manager'
require 'menu/menu_generator'
require 'menu/menu_config'
require 'menu/menu_main'
require 'menu/menu_scheduled'
require 'setup_wizard'

# Main program
class JiraLogwork
  def self.boot
    parse_main_arguments
  rescue ConfigurationJiraURLNotFound
    Utilities.log('JIRA Server URL not set. Did you run the initial setup wizard (jira-worklog setup)?',
                  { type: :error })
  end

  # Parse command-line arguments for main menu
  def self.parse_main_arguments
    menu = MenuGenerator.make_main_menu
    extra_input = {
      config: menu[:config],
      scheduled: menu[:scheduled]
    }
    extra_procs = {
      config: proc { parse_config_arguments },
      scheduled: proc { parse_scheduled_arguments }
    }
    MenuMain.new(menu, extra_input, extra_procs)
  end

  def self.parse_config_arguments
    MenuConfig.new(MenuGenerator.make_config_menu)
  end

  def self.parse_scheduled_arguments
    MenuScheduled.new(MenuGenerator.make_scheduled_menu)
  end
end

# Start application
JiraLogwork.boot
