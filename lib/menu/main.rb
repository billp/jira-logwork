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

require "menu/base"
require "setup_wizard"

module Menu
  # MenuMain handlers
  class Main < Base
    def create_input_map
      {
        setup: menu[:setup],
        login: menu[:login],
        logout: menu[:logout]
      }
    end

    def create_procs_map
      {
        setup: proc { run_setup },
        login: proc { run_login },
        logout: proc { run_logout }
      }
    end

    # Login user
    def run_login
      if Communication::SessionManager.logged_in?
        Utilities.log("You are already logged in.", { type: :info })
      else
        Utilities.log("Please enter your login credentials.")
        SetupWizard.new.configure_login_credentials
      end
    end

    # Logout user
    def run_logout
      Communication::SessionManager.logout
      Utilities.log("Logout success.", { type: :success })
    rescue LogworkException::UserNotLoggedIn => e
      Utilities.log(e, { type: :error })
    end

    # Run setup wizard
    def run_setup
      SetupWizard.new.run
    end
  end
end
