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
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.encrypt
    cipher.key = Digest::SHA256.digest(CREDENTIALS_KEY)
    iv = cipher.random_iv
    { cipher: cipher.update(password) + cipher.final,
      iv: iv }
  end

  def decrypt(cipher, iv_data)
    decipher = OpenSSL::Cipher.new('aes-256-cbc')
    decipher.iv = iv_data
    decipher.decrypt
    decipher.key = Digest::SHA256.digest(CREDENTIALS_KEY)
    decipher.update(cipher) + decipher.final
  end
end
