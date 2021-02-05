# Copyright © 2020-2021. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in the
# Software without restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies
# or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
      list: proc { run_list }
    }
  end

  def create_input_map
    {
      url: menu[:url],
      shift_start: menu[:shift_start],
      shift_end: menu[:shift_end],
      list: menu[:list]
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
  def run_list
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
