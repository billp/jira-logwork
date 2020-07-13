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
