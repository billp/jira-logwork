require "rspec"
require "menu/parser"
require "menu/main"
require "logwork_exception"
require "faraday"

describe "Run jira-logwork" do
  before(:each) do
    ARGV.delete("--pattern")
  end

  context "no command given" do
    it "prints help menu" do
      expect { Menu::Parser.parse_main_arguments }.to output(/setup\s+Run the initial setup wizard./).to_stdout
      expect { Menu::Parser.parse_main_arguments }.to output(/login\s+Login with your JIRA credentials./).to_stdout
      expect { Menu::Parser.parse_main_arguments }.to output(/logout\s+Logout current user./).to_stdout
      expect { Menu::Parser.parse_main_arguments }.to output(/config\s+Update configuration./).to_stdout
      expect { Menu::Parser.parse_main_arguments }.to output(/scheduled\s+Manage scheduled issues./).to_stdout
      expect { Menu::Parser.parse_main_arguments }.to output(/--version, -v\s+Prints jira-logwork version./).to_stdout
    end
  end

  context "setup" do
    describe "jira url" do
      it "user enters valid url" do
        ARGV << "setup"

        allow($stdin).to receive(:gets).and_return("http://www.google.com", "10:00", "18:00", "username", "passw123")
        expectation = expect { Menu::Parser.parse_main_arguments }
        expectation.to output(%r{Please enter the JIRA Server URL: http://www.google.com\nWhat time is your shift}).to_stdout

        ARGV.shift
      end

      it "user enters invalid url" do
        ARGV << "setup"

        allow($stdin).to receive(:gets).and_return("gfsgfds", "10:00", "18:00", "username", "passw123")
        expectation = expect { Menu::Parser.parse_main_arguments }
        expectation.to output(/😓 Invalid URL/).to_stdout

        ARGV.shift
      end
    end

    describe "shift start time" do
      it "user enters valid shift start time" do
        ARGV << "setup"

        allow($stdin).to receive(:gets).and_return("http://www.google.com", "10:00", "18:00", "username", "passw123")
        expectation = expect { Menu::Parser.parse_main_arguments }
        expectation.to output(/What time is your shift started\? \(24h format, e\.g\. 10:00\): 10:00\nWhat time is your shift finished/).to_stdout

        ARGV.shift
      end

      it "user enters invalid shift start time" do
        ARGV << "setup"

        allow($stdin).to receive(:gets).and_return("http://www.google.com", "abc", "18:00", "username", "passw123")
        expectation = expect { Menu::Parser.parse_main_arguments }
        expectation.to output(/😓 Invalid time format/).to_stdout

        ARGV.shift
      end
    end

    describe "shift end time" do
      it "user enters valid shift end time" do
        ARGV << "setup"

        allow($stdin).to receive(:gets).and_return("http://www.google.com", "10:00", "18:00", "username", "passw123")
        expectation = expect { Menu::Parser.parse_main_arguments }
        expectation.to output(/What time is your shift finished\? \(24h format, e\.g\. 18:00\): 18:00\nUsername/).to_stdout

        ARGV.shift
      end

      it "user enters invalid shift end time" do
        ARGV << "setup"

        allow($stdin).to receive(:gets).and_return("http://www.google.com", "10:00", "fdsafdsa", "username", "passw123")
        expectation = expect { Menu::Parser.parse_main_arguments }
        expectation.to output(/😓 Invalid time format/).to_stdout

        ARGV.shift
      end
    end

    describe "username" do
      it "user enters valid username" do
        ARGV << "setup"

        allow($stdin).to receive(:gets).and_return("http://www.google.com", "10:00", "18:00", "username", "passw123")
        expectation = expect { Menu::Parser.parse_main_arguments }
        expectation.to output(/Username: username\nPassword:/).to_stdout

        ARGV.shift
      end

      it "user enters invalid username" do
        ARGV << "setup"

        allow($stdin).to receive(:gets).and_return("http://www.google.com", "10:00", "18:00", "", "passw123")
        expectation = expect { Menu::Parser.parse_main_arguments }
        expectation.to output(/Username: \n 😓 Invalid value/).to_stdout

        ARGV.shift
      end
    end

    describe "password" do
      it "user enters valid password" do
        ARGV << "setup"

        allow($stdin).to receive(:gets).and_return("http://www.google.com", "10:00", "18:00", "username", "passw123")
        expectation = expect { Menu::Parser.parse_main_arguments }
        expectation.to output(/Username: username\nPassword:/).to_stdout

        ARGV.shift
      end

      it "user enters invalid username" do
        ARGV << "setup"

        allow($stdin).to receive(:gets).and_return("http://www.google.com", "10:00", "18:00", "username", "")
        expectation = expect { Menu::Parser.parse_main_arguments }
        expectation.to output(/Password: \n 😓 Invalid value/).to_stdout

        ARGV.shift
      end
    end

    describe "login" do
      it "user logs in successfully" do
        ARGV << "setup"

        # Mock data
        body = { session: { name: "fake_session", value: "bbbqqq" } }
        res = { status: 200 }
        myself = { full_name: "John Doe" }

        # Stub login API call
        allow(Communication::Communicator.instance).to receive(:post)
          .with("/rest/auth/#{Constants::JIRA_AUTH_VERSION}/session", anything)
          .and_yield(body, res)

        # Stub myself API call
        allow(Communication::Communicator.instance).to receive(:get)
          .with("#{Communication::Communicator.base_api_url}/myself")
          .and_return(myself)

        allow($stdin).to receive(:gets).and_return("http://www.google.com", "10:00", "18:00", "username", "passw123")
        expect { Menu::Parser.parse_main_arguments }.to output(/ 🎉 Success \(John Doe\)\./).to_stdout

        ARGV.shift
      end

      it "user has entered invalid username or password" do
        ARGV << "setup"

        # Mock data
        res = Object.new
        allow(res).to receive_message_chain(:env, :url).and_return("https://tst.com/rest/auth/")
        allow(res).to receive(:status).and_return(401)

        # Stub login API call
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(res)

        allow($stdin).to receive(:gets).and_return("http://www.google.com", "10:00", "18:00", "username", "wrongpass")
        expectation = expect { Menu::Parser.parse_main_arguments }
        expectation.to output(/ 😓 Invalid username or password./).to_stdout

        ARGV.shift
      end
    end
  end
end
