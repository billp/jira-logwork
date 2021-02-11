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

require "models/modules/hashable_init"

module LogworkException
  # Configuration Exceptions
  class ConfigurationValueNotFound < StandardError; end

  class ConfigurationFileNotFound < StandardError; end

  class ConfigurationJiraURLNotFound < ConfigurationValueNotFound; end

  # Communicator Exceptions
  class UserAlreadyLoggedIn < StandardError; end

  class UserNotLoggedIn < StandardError; end

  class InvalidCredentials < StandardError; end

  class InvalidURL < StandardError; end

  class APIResourceNotFound < StandardError; end

  class NotSuccessStatusCode < StandardError; end

  # Worklog
  class InvalidTime < StandardError; end

  class InvalidShiftHoursDuration < StandardError; end

  # Worklog manager
  class InvalidCommand < StandardError; end

  class ArgumentError < StandardError; end

  # Scheduled
  class RepeatedOrScheduledRequired < StandardError; end

  class ScheduledCannotBeCombinedWithRepeated < StandardError; end

  class InvalidRepeatValue < StandardError; end

  class InvalidDateFormat < StandardError; end

  class InputValueRequired < StandardError; end

  class DuplicateIssueFound < StandardError; end

  # Input
  class InputIsRequired < StandardError; end
end
