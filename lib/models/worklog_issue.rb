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

require 'active_record'

# WorklogIssue model
class WorklogIssue < ActiveRecord::Base
  before_save :set_status, :check_duplicate

  # JIRA issue id description.
  attribute :jira_id
  # JIRA description.
  attribute :description
  # The duration passed as String, e.g. 2h30m.
  attribute :duration
  # The duration converted to seconds e.g. 2 * 60 * 60 + 30 * 60 = 9000.
  attribute :converted_duration
  # The start time of issue in 24h format, e.g. 14:00.
  attribute :start_time
  # The date that the issue will be scheduled in MM/DD/YYYY format
  attribute :date
  # An integer that indicates the day of the week that this issue will be repeated.
  # 0: Every day, 1: Monday, 2: Tuesday, 3: Wednesday, 4: Thursday, 5: Friday, 6: Saturday, 7: Sunday
  attribute :repeat
  # The adjustment mode. See AdjustmentMode module.
  enum adjustment_mode: %i[auto fixed]

  # rubocop:disable Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/CyclomaticComplexity
  def ==(other)
    jira_id == other.jira_id &&
      description == other.description &&
      duration == other.duration &&
      converted_duration == other.converted_duration &&
      start_time == other.start_time &&
      date == other.date &&
      repeat == other.repeat &&
      adjustment_mode == other.adjustment_mode
  end
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/CyclomaticComplexity

  private

  def set_status
    self.adjustment_mode = duration.nil? ? :auto : :fixed
  end

  def check_duplicate
    return if WorklogIssue.where({ jira_id: jira_id, description: description, duration: duration,
                                   start_time: start_time, date: date, repeat: repeat }).count.zero?

    raise DuplicateIssueFound.new, 'Issue already exists with the given parameters.'
  end
end
