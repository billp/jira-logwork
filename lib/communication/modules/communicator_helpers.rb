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

require "logwork_exception"

module Communication
  # Communicator helpers
  module CommunicatorHelpers
    def check_unauthorized(status, url)
      return unless status == 401 && auth_call?(url)

      raise LogworkException::InvalidCredentials.new, "Login failed! Please check your credentials."
    end

    def check_not_found(status)
      raise LogworkException::APIResourceNotFound.new, "API resource not found." if status == 404
    end

    def check_not_success(status)
      raise LogworkException::NotSuccessStatusCode.new, "Not success response." if status / 200 != 1
    end

    def handle_success(body)
      json_body = Utilities.valid_json?(body) ? parse_json(body) : parse_json({})
      yield(json_body) if block_given?
    end

    def should_relogin(res)
      !relogin_performed && !auth_call?(res.env.url.to_s) && res.status == 401
    end

    def auth_call?(path)
      path.include?("/rest/auth/")
    end

    def relogin
      # read credentials from configuration file configuration
      Utilities.remove_cookie
      conn.headers.delete("Cookie")
      Communication::SessionManager.new(CredentialsConfiguration.new.login_credentials).login(force: true)
      self.relogin_performed = true
      cached_request_callback.call(cached_success_callback)
    end
  end
end
