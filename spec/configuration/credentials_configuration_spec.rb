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
require "configuration/credentials_configuration"
require "constants"

describe Configuration do
  describe Configuration::CredentialsConfiguration do
    describe "decrypted_password" do
      it "password should be decrypted" do
        Configuration::CredentialsConfiguration
          .new
          .update_login_credentials("user", "pass")

        expect(Configuration::CredentialsConfiguration.new.decrypted_password).to eq("pass")
      end
    end

    describe "login_credentials" do
      it "should get login credentials" do
        Configuration::CredentialsConfiguration
          .new
          .update_login_credentials("user2", "pass2")

        credentials = Configuration::CredentialsConfiguration.new.login_credentials
        expect(credentials.username).to eq("user2")
        expect(credentials.password).to eq("pass2")
        expect(credentials.is_stored).to be(true)
      end

      describe "login_credentials_empty?" do
        it "should be empty" do
          allow_any_instance_of(Configuration::CredentialsConfiguration)
            .to receive(:data)
            .and_return(nil)

          expect(Configuration::CredentialsConfiguration.new.login_credentials_empty?).to be(true)
        end

        it "should not be empty" do
          allow_any_instance_of(Configuration::CredentialsConfiguration)
            .to receive(:data)
            .and_return(
              {
                credentials: {
                  username: "johndoe",
                  password: "tetstttttt"
                }
              }
            )

          expect(Configuration::CredentialsConfiguration.new.login_credentials_empty?).to be(false)
        end
      end
    end

    describe "update_login_credentials" do
      it "should set login credentials" do
        Configuration::CredentialsConfiguration
          .new
          .update_login_credentials("user", "pass")
        credentials = Configuration::CredentialsConfiguration.new.login_credentials
        expect(credentials.username).to eq("user")
        expect(credentials.password).to eq("pass")
      end

      it "should set login credentials" do
        Configuration::CredentialsConfiguration
          .new
          .update_login_credentials("user2_updated", "pass2_updated")

        credentials = Configuration::CredentialsConfiguration.new.login_credentials
        expect(credentials.username).to eq("user2_updated")
        expect(credentials.password).to eq("pass2_updated")
        expect(credentials.is_stored).to be(true)
      end
    end
  end
end
