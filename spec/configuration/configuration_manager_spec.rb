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

require "rspec"
require "configuration/configuration_manager"
require "constants"

describe Configuration do
  before(:each) do
    allow(Configuration::ConfigurationManager).to receive(:create_config_dir_if_needed)
  end

  describe Configuration::ConfigurationManager do
    describe "jira_server_url" do
      it "should throw configuration not found" do
        expect { Configuration::ConfigurationManager.instance.jira_server_url }
          .to raise_error(LogworkException::ConfigurationJiraURLNotFound)
      end
    end

    describe "update_jira_server_url" do
      it "update value" do
        Configuration::ConfigurationManager.instance.update_jira_server_url("http://www.google.com/abc")
        expect(Configuration::ConfigurationManager.instance.jira_server_url).to eq("http://www.google.com/abc")
      end
    end

    describe "save_configuration" do
      it "should save configuration" do
        allow(Configuration::ConfigurationManager.instance).to receive(:configuration_data).and_return(conf: "test")
        expect(Configuration::ConfigurationManager.instance.save_configuration).to include(conf: "test")
      end

      it "should raise LogworkException::ConfigurationFileNotFound" do
        allow(Configuration::ConfigurationManager.instance).to receive(:configuration_data).and_return(conf: "test")
        allow(Configuration::ConfigurationManager.instance).to receive(:configuration_writable?).and_return(false)
        expect { Configuration::ConfigurationManager.instance.save_configuration }
          .to raise_error(LogworkException::ConfigurationFileNotFound)
      end
    end

    describe "configuration_path" do
      it "should return valid directory" do
        path = Configuration::ConfigurationManager.instance.configuration_path
        expect(File.file?(path)).to be(true)
      end
    end
  end
end
