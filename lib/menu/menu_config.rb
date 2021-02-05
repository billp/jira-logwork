# frozen_string_literal: true

require 'menu/menu'
require 'configuration/shift_configuration'

# MenuConfig handlers
class MenuConfig < Menu
  def create_procs_map
    {
      url: proc { set_url },
      shift_start: proc { set_shift_start },
      shift_end: proc { set_shift_end },
      print: proc { run_print }
    }
  end

  def create_input_map
    {
      url: menu[:url],
      shift_start: menu[:shift_start],
      shift_end: menu[:shift_end],
      print: menu[:print]
    }
  end

  # Set JIRA URL.
  def set_url
    ConfigurationManager.instance.update_jira_server_url(menu[:url])
  rescue InvalidURLException
    Utilities.log('Invalid JIRA server URL.', { type: :error })
  end

  # Set shift start time.
  def set_shift_start
    ShiftConfiguration.new.update_shift_start(menu[:shift_start])
  rescue InvalidTimeException
    Utilities.log('Invalid starttime format.', { type: :error })
  end

  # Set shift end time.
  def set_shift_end
    ShiftConfiguration.new.update_shift_end(menu[:shift_end])
  rescue InvalidTimeException
    Utilities.log('Invalid end time format.', { type: :error })
  end

  # rubocop:disable Metrics/AbcSize
  def run_print
    values = [
      { key: :url, value: proc { ConfigurationManager.instance.jira_server_url } },
      { key: :shift_start, value: proc { ShiftConfiguration.new.shift_start } },
      { key: :shift_end, value: proc { ShiftConfiguration.new.shift_end } },
      { key: :username, value: proc { CredentialsConfiguration.new.login_credentials.username } },
      { key: :password, value: proc { !CredentialsConfiguration.new.login_credentials.password.nil? ? '****' : nil } }
    ]

    values.each { |v| print_config_value(v) }
  end
  # rubocop:enable Metrics/AbcSize

  def print_config_value(value)
    puts "#{value[:key]}=#{value[:value].call}"
  rescue ConfigurationValueNotFound
    puts "#{value[:key]}=[not-set]"
  end
end