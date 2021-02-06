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
class ShiftConfiguration < Configuration
  # Read shift start.
  #
  # @return [String] The shift start time value, e.g. '10:00'
  def shift_start
    validate_saved_shift_start

    shift_start = data[:shift][:start]
    unless Utilities.valid_time?(shift_start)
      raise InvalidTimeException.new, "Invalid shift start time format in '#{manager.configuration_path}'."
    end

    data[:shift][:start]
  end

  def validate_saved_shift_start
    return if !data[:shift].nil? && !data[:shift][:start].nil?

    raise ConfigurationValueNotFound.new,
          "Cannot read shift start time from configuration file at '#{manager.configuration_path}'."
  end

  # Update shift start in configuration file.
  def update_shift_start(shift_start)
    raise InvalidTimeException.new, 'Invalid start time format.' unless Utilities.valid_time?(shift_start)

    shift = data[:shift] || {}
    shift[:start] = shift_start
    data[:shift] = shift
    manager.save_configuration
  end

  # Read shift end.
  #
  # @return [String] The shift end time value, e.g. '18:00'
  def shift_end
    validate_saved_shift_end
    shift_end = data[:shift][:end]
    unless Utilities.valid_time?(shift_end)
      raise InvalidTimeException.new, "Invalid end time formats in '#{manager.configuration_path}'."
    end

    data[:shift][:end]
  end

  def validate_saved_shift_end
    return if !data[:shift].nil? && !data[:shift][:end].nil?

    raise ConfigurationValueNotFound.new,
          "Cannot read shift end time from configuration file at '#{manager.configuration_path}'."
  end

  # Update shift end time in configuration file.
  def update_shift_end(shift_end)
    raise InvalidTimeException.new, 'Invalid end time format.' unless Utilities.valid_time?(shift_end)

    shift = data[:shift] || {}
    shift[:end] = shift_end
    data[:shift] = shift
    manager.save_configuration
  end

  # Shift duration in hours.
  #
  # @return [Int] The duration in hours between shift end and shift start
  def shift_duration
    duration = Utilities.time_diff_hours(shift_start, shift_end)

    if duration < 1 || duration > 24
      raise InvalidShiftHoursDurationException.new,
            'Unable to calculate your shift hours. Configuration values shift_start and/or shift_end are invalid.'
    end

    duration
  end
end
