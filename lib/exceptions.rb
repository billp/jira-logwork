# Configuration Exceptions
class ConfigurationValueNotFound < StandardError; end
class ConfigurationFileNotFoundException < StandardError; end

# Communicator Exceptions
class UserAlreadyLoggedInException < StandardError; end
class UserNotLoggedInException < StandardError; end
class InvalidCredentialsException < StandardError; end
class InvalidURLException < StandardError; end

# Worklog
class InvalidTimeException < StandardError; end
class InvalidShiftHoursDurationException < StandardError; end