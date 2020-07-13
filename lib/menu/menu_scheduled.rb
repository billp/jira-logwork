# frozen_string_literal: true

require 'menu/menu'
require 'scheduled/scheduled_issues_manager'
require 'database'
require 'terminal-table'

# MenuConfig handlers
class MenuScheduled < Menu
  def create_procs_map
    {
      add: proc { add_scheduled },
      remove: proc { remove_scheduled },
      list: proc { list_scheduled }
    }
  end

  def create_input_map
    {
      add: menu[:add],
      remove: menu[:remove],
      list: menu[:list]
    }
  end

  # Add scheduled issue.
  def add_scheduled
    Database.prepare_database
    ScheduledIssuesManager.new.add_scheduled(menu[:add], menu[:repeat],
                                             menu[:date], menu[:start_time],
                                             menu[:duration])
  end

  # Remove scheduled issue.
  def remove_scheduled
    Database.prepare_database
    deleted_count = ScheduledIssuesManager.new.remove_scheduled(menu[:remove], menu[:date], menu[:repeat])
    if deleted_count.positive?
      Utilities.log("#{deleted_count} issues deleted.")
    else
      Utilities.log('No issue(s) found with the given options.')
    end
  end

  # List scheduled issues.
  def list_scheduled
    Database.prepare_database
    rows = ScheduledIssuesManager.new.all_issues.map { |i| list_row_attributes(i) }
    table = Terminal::Table.new headings: list_headings, rows: rows
    if rows.count.positive?
      puts table
    else
      Utilities.log('Scheduled list is empty.')
    end
  end

  private

  def list_row_attributes(issue)
    [
      issue.jira_id, issue.description,
      issue.date || '-', issue.start_time || '-',
      issue.duration || '-', issue.repeat || '-'
    ]
  end

  def list_headings
    ['Issue ID', 'Description', 'Date', 'Start Time', 'Duration', 'Repeat']
  end
end
