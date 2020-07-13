# frozen_string_literal: true

require 'configuration/configuration'

# Configuration for credentials.
class CredentialsConfiguration < Configuration
  # Read credentials from configuration file
  #
  # @return [AccountCredentials] An AccountCredentials instance with username, password and is_stored properties.
  def login_credentials
    if login_credentials_empty?
      raise ConfigurationValueNotFound.new,
            "Cannot read username/password from configuration file at '#{manager.configuration_path}'."
    end

    AccountCredentials.new(username: data[:credentials][:username],
                           password: decrypted_password,
                           is_stored: true)
  end

  def login_credentials_empty?
    data[:credentials].nil? ||
      data[:credentials][:username].nil? ||
      data[:credentials][:password].nil?
  end

  def decrypted_password
    decrypt(data[:credentials][:password][:cipher],
            data[:credentials][:password][:iv])
  end

  # Update login credentials in configuration file
  #
  # @param username [String] Jira username
  # @param password [String] Jira password
  def update_login_credentials(username, password)
    if !username.nil? && !password.nil?
      encrypted_password = encrypt(password)
      data[:credentials] = {
        username: username,
        password: encrypted_password
      }
    else
      data.delete(:credentials)
    end

    manager.save_configuration
  end

  private

  CREDENTIALS_KEY = 'kserw-gw?-vale kati -edw!@#!@!#@&!#@!'

  def encrypt(password)
    cipher = OpenSSL::Cipher::AES256.new :CBC
    cipher.encrypt
    cipher.key = Digest::SHA256.digest(CREDENTIALS_KEY)
    iv = cipher.random_iv
    { cipher: cipher.update(password) + cipher.final,
      iv: iv }
  end

  def decrypt(cipher, iv_data)
    decipher = OpenSSL::Cipher::AES256.new :CBC
    decipher.iv = iv_data
    decipher.decrypt
    decipher.key = Digest::SHA256.digest(CREDENTIALS_KEY)
    decipher.update(cipher) + decipher.final
  end
end
