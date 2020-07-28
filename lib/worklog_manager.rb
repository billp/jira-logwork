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

# frozen_string_literal: true

require_relative 'worklog_manager/worklog_command.rb'

# Worklog manager
class WorklogManager
  # Construct
  # @param workday_hours [Integer] The total hours of a workday, e.g. 8
  def initialize(initial_issues = [], workday_hours = 8)
    @workday_hours = workday_hours
    @issues = initial_issues
  end

  # Updates the daily worklog table by applying the given command.
  #
  # @param command [String] The command that will be applied to the issues parameter. The available commands are:
  #                         - move | m [pos1] [pos2] (e.g. 'm 2 1', it moves the issue from position 1 to position 2
  #                         (swipes issues)
  #                         - duration | d [pos] [duration] (e.g. 'd 3 30m', it changes the duration of the issue
  #                                  at position 3 to 30 minutes).
  #                                 Pass 'auto' to automatically expand the duration to fill the required working hours.
  #                         - remove | r [pos] (e.g 'r 3', remove from the position 3)
  #                         - insert | i [pos] (e.g 'i 3', insert into position 3. Pos parameter can be omitted and
  #                                  the new
  #                                 issue will be inserted at the end )
  # @param issues [Array<WorklogIssue>] The array of worklog issues.
  #
  # @return [Array<WorklogIssue>] The updated array of work log issues.
  # @raise InvalidCommandException
  # @raise ArgumentError
  def update_worklog(command, issue_to_add: nil)
    command_found = get_command(command.strip)
    raise InvalidCommandException, 'Wrong command' if command.nil? || command.empty? || command_found.nil?

    command_found.update_issues(@issues, issue_to_add)
  end

  # Adjusts the issues
  def adjust
    fill_auto_durations
    static_issues
  end

  private

  # Fill durations for auto issues.
  def fill_auto_durations
    @issues.select { |issue| issue.adjustment_mode == 'auto' }
           .each { |issue| issue.converted_duration = auto_duration }
  end

  # Issues that will be automatically adjusted.
  def auto_issues
    @issues.select { |issue| issue.adjustment_mode == 'auto' }
  end

  # Issues that has fixed duration.
  def fixed_issues
    @issues.select { |issue| issue.adjustment_mode == 'fixed' }
  end

  # Total duration of fixed issues.
  def total_fixed_duration
    fixed_issues.reduce(0) { |res, issue| res + issue.converted_duration }
  end

  # Issues that have start time and duration.
  def static_issues
    fixed_issues.reject { |issue| issue.converted_start_time.nil? }
                .sort { |a, b| a.converted_start_time <=> b.converted_start_time }
  end

  # The single-issue duration the issue needs to be filled.
  def auto_duration
    available_duration / auto_issues.count
  end

  def available_duration
    @workday_hours * 60 * 60 - total_fixed_duration
  end

  # Represent command and class name
  COMMANDS = {
    m: 'MoveWorklogCommand',
    d: 'DurationWorklogCommand',
    i: 'InsertWorklogCommand',
    r: 'RemoveWorklogCommand',
    s: 'StartTimeWorklogCommand'
  }.freeze

  # Return the command executor object
  # @param [String] total_command Should be stripped from spaces
  def get_command(total_command)
    return if total_command.empty?

    command_code = total_command[0].to_sym
    arguments = total_command[1, total_command.size - 1] || ' '

    class_name = COMMANDS[command_code]
    # puts "Got classname #{class_name} for command #{command_code}"
    Object.const_get(class_name).new(arguments, @workday_hours) unless class_name.nil?
  end
end
