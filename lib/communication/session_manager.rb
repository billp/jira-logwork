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

require "communication/communicator"
require "logwork_exception"

module Communication
  # Manages user session
  class SessionManager
    def initialize(account_credentials)
      self.credentials = account_credentials
    end

    # Logs in a user or prompts with login credentials if it's not logged in.
    #
    # @param force [Bool] Pass true to force login regardleess of login state.
    def login(force: false)
      if SessionManager.logged_in? && !force
        raise LogworkException::UserAlreadyLoggedIn.new,
              "You are already logged in."
      end

      params = {
        "username" => credentials.username,
        "password" => credentials.password
      }

      Communicator.instance.post("/rest/auth/#{Constants::JIRA_AUTH_VERSION}/session", params) do |body, res|
        parse_login_response(body, res) { yield if block_given? }
      end
    end

    def parse_login_response(body, _)
      handle_login_success(body) do
        yield if block_given?
      end
    end

    def handle_login_success(body)
      unless credentials.is_stored
        # store credentials
        Configuration::CredentialsConfiguration.new.update_login_credentials(credentials.username,
                                                                             credentials.password)
      end

      store_cookie(body)
      yield if block_given?
    end

    def store_cookie(body)
      return unless body.is_a?(Hash)

      cookie = "#{body[:session][:name]}=#{body[:session][:value]}"
      Communicator.instance.update_cookie_header(cookie)
      Utilities.store_cookie(cookie)
    end

    # Log out the currently logged in user.
    def self.logout
      raise LogworkException::UserNotLoggedIn.new, "You are not logged in." unless logged_in?

      Communicator.instance.delete("/rest/auth/#{Constants::JIRA_AUTH_VERSION}/session") do
        Utilities.remove_cookie
        CredentialsConfiguration.new.update_login_credentials(nil, nil)
      end
    end

    # Returns returns true if user is logged in.
    #
    # @return [Boolean] True if user is logged in, false otherwise.
    def self.logged_in?
      Utilities.cookie_exists? && !CredentialsConfiguration.new.login_credentials.nil?
    rescue StandardError
      false
    end

    # Returns information about the logged in user.
    #
    # @return [Hash] User info.
    def myself
      Communicator.instance.get("#{Communicator.base_api_url}/myself") do |body, _|
        raise LogworkException::InvalidURL unless body.is_a?(Hash)

        { full_name: body[:displayName] }
      end
    end

    private

    attr_accessor :credentials
  end
end
