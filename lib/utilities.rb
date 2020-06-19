require 'fileutils'
require 'constants'

class Utilities
    LOG_SYMBOLS = {
      info: '￫ ',
      success: '🎉',
      error: '😓',
      none: ''
    }

    ENCRYPTED_STORE_KEY = 'JIRA-LOGWORK'
    TEMP_FOLDER_NAME = 'tmp'
    COOKIE_FILE_NAME = '.cookie'

    # Logs a message to console.
    #
    # @param message [String] The message to log.
    # @param type [Symbol] Log type, `:info`, `:success`, `:error` or `:none`.
    def self.log(message, options = {})
        type = options[:type] || :info
        newline = options[:newline] || true

        print "#{LOG_SYMBOLS[type] ? ' ' + LOG_SYMBOLS[type] + ' ' : ''}#{message}" + (newline ? "\n" : '')
    end

    # Stores session cookie in tmp folder.
    #
    # @param cookie [String] The cookie string value.
    def self.store_cookie(cookie)
      unless File.directory?(temp_folder_path)
        FileUtils.mkdir_p(temp_folder_path)
      end

      File.write(cookie_file_path, cookie)
    end

    # Removes the stored cookie if exists.
    def self.remove_cookie()
      if File.file?(cookie_file_path)
        File.delete(cookie_file_path)
      end
    end

    # Retrieves session cookie if available.
    #
    # @return [String] Cookie value or nil
    def self.retrieve_cookie()
      if cookie_exists?
        File.read(cookie_file_path)
      end
    end

    # Check if cookie file exist
    #
    # @return [Boolean] True if cookie file exists, false otherwise.
    def self.cookie_exists?
      File.file?(cookie_file_path)
    end

    private
      def self.temp_folder_path
        File.expand_path(File.join(Dir.home, Constants::ROOT_FOLDER_NAME, TEMP_FOLDER_NAME))
      end

      def self.cookie_file_path
        File.join(temp_folder_path, COOKIE_FILE_NAME)
      end
end