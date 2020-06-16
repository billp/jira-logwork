class Utilities
    LOG_SYMBOLS = {
      info: '￫ ',
      success: '🎉',
      error: '😓',
      none: ''
    }
    KEYCHAIN_KEY = 'JIRAOMNIA'


    def self.log(message, options = {})
        type = options[:type] || :info
        newline = options[:newline] || true

        print "#{LOG_SYMBOLS[type] ? ' ' + LOG_SYMBOLS[type] + ' ' : ''}#{message}" + (newline ? "\n" : '')
    end
end