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

require "models/account_credentials"
require "communication/communicator"
require "configuration/credentials_configuration"
require "configuration/shift_configuration"
require "communication/session_manager"
require "prompt"

# Setup wizard
class SetupWizard
  def run
    Utilities.log("Welcome to jira-logwork configuration wizard.\n")
    configure_jira_url
    configure_shift_start
    configure_shift_end
    configure_login_credentials
  end

  # Promts for the JIRA server url until user enters a valid value.
  def configure_jira_url
    loop do
      begin
        Configuration::ConfigurationManager
          .instance.update_jira_server_url prompt.ask("Please enter the JIRA Server URL:")
        break
      rescue LogworkException::InvalidURL
        Utilities.log("Invalid URL", { type: :error })
        # Break in case of rspec
        Utilities.rspec_running? && break
      end
    end
  end

  # Promts for shift start until user enters a valid value.
  def configure_shift_start
    loop do
      begin
        Configuration::ShiftConfiguration.new.update_shift_start(
          prompt.ask("What time is your shift started? (24h format, e.g. 10:00):")
        )
        break
      rescue LogworkException::InvalidTime
        Utilities.log("Invalid time format", { type: :error })
        # Break in case of rspec
        Utilities.rspec_running? && break
      end
    end
  end

  # Promts for shift end until user enters a valid value.
  def configure_shift_end
    loop do
      begin
        Configuration::ShiftConfiguration.new.update_shift_end(
          prompt.ask("What time is your shift finished? (24h format, e.g. 18:00):")
        )
        break
      rescue LogworkException::InvalidTime
        Utilities.log("Invalid time format", { type: :error })

        # Break in case of rspec
        Utilities.rspec_running? && break
      end
    end
  end

  # Prompts for login credentials and executes login API call.
  def configure_login_credentials
    # Clear saved cookie
    Utilities.remove_cookie

    account = prompt_for_account
    Utilities.log("Trying to login...")
    session = Communication::SessionManager.new(account)
    session.login(force: true) do
      Utilities.log("Success (#{session.myself[:full_name]}).", { type: :success })
    end
  rescue LogworkException::InvalidCredentials
    Utilities.log("Invalid username or password.", { type: :error })
  rescue LogworkException::APIResourceNotFound, LogworkException::NotSuccessStatusCode
    Utilities.log("Seems that you have entered an invalid JIRA Server URL.", { type: :error })
  end

  private

  # Creates prompt object
  def prompt
    Prompt.new
  end

  def prompt_for_account
    begin
      account = Configuration::CredentialsConfiguration.new.login_credentials
    rescue LogworkException::ConfigurationValueNotFound
      account = Model::AccountCredentials.new(username: nil, password: nil, is_stored: false)
    end

    account.username = prompt_for_username
    account.password = prompt_for_password
    account
  end

  def prompt_for_username
    loop do
      begin
        return prompt.ask("Username:", { required: true })
      rescue LogworkException::InputIsRequired
        Utilities.log("Invalid value", { type: :error })

        # Break in case of rspec
        Utilities.rspec_running? && break
      end
    end
  end

  def prompt_for_password
    loop do
      begin
        return prompt.mask("Password:", { required: true })
      rescue LogworkException::InputIsRequired
        Utilities.log("Invalid value", { type: :error })

        # Break in case of rspec
        Utilities.rspec_running? && break
      end
    end
  end
end
