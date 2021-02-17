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
