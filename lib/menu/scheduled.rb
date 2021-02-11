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

require "menu/base"
require "scheduled/scheduled_issues_manager"
require "database"
require "terminal-table"

module Menu
  # MenuConfig handlers
  class Scheduled < Base
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
        Utilities.log("#{deleted_count} #{Utilities.pluralize(deleted_count, 'issue', 'issues')} deleted.")
      else
        Utilities.log("No issues found with the given options.", { type: :error })
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
        Utilities.log("Scheduled list is empty.")
      end
    end

    private

    def list_row_attributes(issue)
      [
        issue.jira_id, issue.description,
        issue.date || "-", issue.start_time || "-",
        issue.duration || "-", issue.repeat || "-"
      ]
    end

    def list_headings
      ["Issue ID", "Description", "Date", "Start Time", "Duration", "Repeat"]
    end
  end
end
