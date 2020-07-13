# frozen_string_literal: true

require 'models/modules/hashable_init'

# Configuration Exceptions
class ConfigurationValueNotFound < StandardError; end
class ConfigurationFileNotFoundException < StandardError; end
class ConfigurationJiraURLNotFound < ConfigurationValueNotFound; end

# Communicator Exceptions
class UserAlreadyLoggedInException < StandardError; end
class UserNotLoggedInException < StandardError; end
class InvalidCredentialsException < StandardError; end
class InvalidURLException < StandardError; end
class APIResourceNotFoundException < StandardError; end
class NotSuccessStatusCodeException < StandardError; end

# Worklog
class InvalidTimeException < StandardError; end
class InvalidShiftHoursDurationException < StandardError; end

# Worklog manager
class InvalidCommandException < StandardError; end

# Scheduled
class RepeatedOrScheduledRequired < StandardError; end
class ScheduledCannotBeCombinedWithRepeated < StandardError; end
class InvalidRepeatValue < StandardError; end
class InvalidDateFormat < StandardError; end
class InputValueRequired < StandardError; end
class DuplicateIssueFound < StandardError; end
