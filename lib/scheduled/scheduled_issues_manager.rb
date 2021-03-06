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

require "utilities"
require "logwork_exception"
require "communication/api"
require "models/logwork_issue"

# Configuration for repeatables.
class ScheduledIssuesManager
  # Adds a scheduled issue to database.
  #
  # @param issue_id [String] The JIRA issue id.
  # @param repeat [Integer] An integer that indicates the day of the week that this issue will be repeated.
  #                             0: Every day
  #                             1: Monday
  #                             2: Tuesday
  #                             3: Wednesday
  #                             4: Thursday
  #                             5: Friday
  #                             6: Saturday
  #                             7: Sunday
  # @param date [String] A date that the issue will be scheduled in MM/DD/YYYY format.
  # @param start_time [String] The String representation of start time in 24h format, e.g. 10:00
  # @param duration [String] A String representation of duration, e.g. 2h30m
  def add_scheduled(issue_id, repeat, date, start_time, duration)
    validate_input(repeat, date, start_time, duration)
    Communication::API.get_issue(issue_id) do |issue|
      update_issue_attributes(issue, repeat, date, start_time, duration).save
      Utilities.log "Added issue #{issue.jira_id}: #{issue.description}.", { type: :info }
    end
  rescue LogworkException::APIResourceNotFound
    Utilities.log("JIRA issue '#{issue_id}' not found.", { type: :error })
  rescue LogworkException::RepeatedOrScheduledRequired, LogworkException::ScheduledCannotBeCombinedWithRepeated,
         LogworkException::InvalidRepeatValue, LogworkException::InvalidDateFormat,
         LogworkException::DuplicateIssueFound, LogworkException::InputValueRequired,
         LogworkException::InvalidTimeException => e
    Utilities.log(e, { type: :error })
  end

  # Updates issue's attributes with command line arguments
  #
  # @param issue [WorklogIssue] The WorklogIssue created by API service.
  # @param repeat [String] A number that indicates the date of the week.
  # @param date [String] The date input of the issue.
  # @param start_time [String] The start time input of the issue.
  # @param duration [String] A String representation of duration, e.g. 2h30m
  def update_issue_attributes(issue, repeat, date, start_time, duration)
    issue.date = date
    issue.start_time = start_time
    issue.repeat = repeat
    issue.duration = duration
    issue
  end

  # Remove a scheduled issue from database.
  #
  # @param issue_id [String] The JIRA issue id.
  # @param date [String] The date of the issue.
  # @param repeat [String] A number that indicates the date of the week.
  def remove_scheduled(issue_id, date, repeat)
    filters = { jira_id: issue_id }
    filters[:date] = date unless date.nil?
    filters[:repeat] = date unless repeat.nil?
    WorklogIssue.where(filters).delete_all
  end

  # Return all scheduled issues.
  #
  # @return [Array<WorklogIssue>] List scheduled issues.
  def all_issues
    WorklogIssue.all
  end

  private

  def validate_input(repeat, date, start_time, duration)
    validate_occurence_of_date_or_repeat(repeat, date)
    validate_exclusive_input(date, repeat)
    validate_repeat(repeat) unless repeat.nil?
    validate_date(date) unless date.nil?
    validate_start_time(start_time) unless start_time.nil?
    validate_duration_occurance(start_time) unless duration.nil?
  end

  def validate_occurence_of_date_or_repeat(repeat, date)
    return unless date.nil? && repeat.nil?

    raise LogworkException::RepeatedOrScheduledRequired.new, "Option --repeat or --date is required."
  end

  def validate_exclusive_input(date, repeat)
    return unless !date.nil? && !repeat.nil?

    raise LogworkException::ScheduledCannotBeCombinedWithRepeated.new, "Option --date cannot be combined with --repeat."
  end

  def validate_repeat(repeat)
    repeat_value = repeat.to_i
    return if Utilities.number?(repeat) && repeat_value >= 0 && repeat_value < 8

    raise LogworkException::InvalidRepeatValue.new,
          "--repeat value should be between 0 and 8."
  end

  def validate_date(date)
    return if Utilities.valid_date?(date)

    raise LogworkException::InvalidDateFormat.new,
          "--date value has invalid format. Please enter a date in 'mm/dd/YYYY' format."
  end

  def validate_start_time(start_time)
    return if Utilities.valid_time?(start_time)

    raise LogworkException::InvalidTimeException.new,
          "--start_time value has invalid format. Please enter a date in 'HH:mm' format."
  end

  def validate_duration_occurance(start_time)
    return if Utilities.valid_time?(start_time)

    raise LogworkException::InputValueRequired.new, "--duration value is required when --start_time is present."
  end
end
