require "rspec"
require "configuration/configuration_manager"
require "constants"
require "byebug"

describe Configuration do
  before(:each) do
    allow(File).to receive(:file?) { |path| InMemoryFS.instance.file?(path) }
    allow(File).to receive(:read) { |path| InMemoryFS.instance.read(path) }
    allow(File).to receive(:write) { |path| InMemoryFS.instance.write(path) }
    allow(File).to receive(:delete) { |path| InMemoryFS.instance.delete?(path) }
  end

  describe Configuration::ConfigurationManager do
    describe "jira_server_url" do
      it "should throw configuration not found" do
        expect { Configuration::ConfigurationManager.instance.jira_server_url }
          .to raise_error(LogworkException::ConfigurationJiraURLNotFound)
      end
    end
  end
end
