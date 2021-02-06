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

require 'models/account_credentials'
require 'communication/communicator'
require 'menu/menu_main'
require 'configuration/credentials_configuration'

# Setup wizard
class SetupWizard
  def run
    Utilities.log("Welcome to jira-logwork configuration wizard.\n")
    configure_jira_url
    configure_shift_start
    configure_shift_end
    configure_login_credentials
  end

  # Promts to set the JIRA server url.
  def configure_jira_url
    loop do
      begin
        ConfigurationManager.instance.update_jira_server_url prompt.ask('Please enter the JIRA Server URL:')
        break
      rescue InvalidURLException
        Utilities.log('Invalid URL', { type: :error })
      end
    end
  end

  # Promts to set the shift start.
  def configure_shift_start
    loop do
      begin
        ShiftConfiguration.new.update_shift_start(
          prompt.ask('What time is your shift started? (24h format, e.g. 10:00):')
        )
        break
      rescue InvalidTimeException
        Utilities.log('Invalid time format', { type: :error })
      end
    end
  end

  # Promts to set the shift end.
  def configure_shift_end
    loop do
      begin
        ShiftConfiguration.new.update_shift_end(
          prompt.ask('What time is your shift finished? (24h format, e.g. 18:00):')
        )
        break
      rescue InvalidTimeException
        Utilities.log('Invalid time format', { type: :error })
      end
    end
  end

  # Promts to login
  def configure_login_credentials
    return if SessionManager.logged_in?

    account = prompt_for_account
    Utilities.log('Trying to login...')
    session = SessionManager.new(account)
    session.login do
      Utilities.log("Success (#{session.myself[:full_name]}).", { type: :success })
    end
  rescue InvalidCredentialsException
    Utilities.log('Invalid username or password.', { type: :error })
  end

  private

  attr_accessor :tty_prompt

  def prompt
    tty_prompt || TTY::Prompt.new
  end

  def prompt_for_account
    begin
      account = CredentialsConfiguration.new.login_credentials
    rescue ConfigurationValueNotFound
      account = AccountCredentials.new(username: nil, password: nil, is_stored: false)
    end

    return if SessionManager.logged_in?

    account.username = prompt.ask('Username:')
    account.password = prompt.mask('Password:')
    account
  end
end
