require 'models/account_credentials'
require 'communicator'

class SetupWizard
  private
    attr_accessor :tty_prompt

    def prompt
      if tty_prompt.nil?
        tty_prompt = TTY::Prompt.new
      end
      tty_prompt
    end
    
  public
    def run
      Utilities.log("Welcome to jira-logwork configuration wizard.\n")
      set_jira_url
      set_shift_start
      set_shift_end
      set_login_credentials
      Utilities.log("Configuration saved successfully.", { type: :success })
    end

    # Promts to set the JIRA server url.
    def set_jira_url
      loop do
        begin
          ConfigurationManager.instance.update_jira_server_url prompt.ask("Please enter the JIRA Server URL:")
          break
        rescue InvalidURLException
          Utilities.log("Invalid URL", { type: :error })
        end
      end
    end

    # Promts to set the shift start.
    def set_shift_start
      loop do
        begin
          ConfigurationManager.instance.update_shift_start prompt.ask("What time is your shift started? (24h format, e.g. 10:00):")
          break
        rescue InvalidTimeException
          Utilities.log("Invalid time format", { type: :error })
        end
      end
    end

    # Promts to set the shift end.
    def set_shift_end
      loop do
        begin
          ConfigurationManager.instance.update_shift_end prompt.ask("What time is your shift finished? (24h format, e.g. 18:00):")
          break
        rescue InvalidTimeException
          Utilities.log("Invalid time format", { type: :error })
        end
      end
    end

    # Promts to login
    def set_login_credentials
      begin
        account = ConfigurationManager.instance.login_credentials
      rescue Exception => e
        account = AccountCredentials.new(username: nil, password: nil, is_stored: false)
      end

      unless Communicator.instance.logged_in?
        account.username = prompt.ask("Username:")
        account.password = prompt.mask("Password:")
      end

      unless Communicator.instance.logged_in?
        Utilities.log("Trying to login...")
        begin
          Communicator.instance.login(account)  
        rescue InvalidCredentialsException
          Utilities.log("Invalid username or password.", { type: :error })
        end
      end
    end
end