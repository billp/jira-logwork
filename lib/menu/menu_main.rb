# frozen_string_literal: true

require 'menu/menu'

# MenuMain handlers
class MenuMain < Menu
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
    if SessionManager.logged_in?
      Utilities.log('You are already logged in.', { type: :success })
    else
      Utilities.log('Please enter your login credentials.')
      SetupWizard.new.configure_login_credentials
    end
  end

  # Logout user
  def run_logout
    SessionManager.logout
    Utilities.log('Logout success.', { type: :success })
  rescue UserNotLoggedInException => e
    Utilities.log(e, { type: :error })
  end

  # Run setup wizard
  def run_setup
    SetupWizard.new.run
  end
end
