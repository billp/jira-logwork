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

require 'sqlite3'
require 'active_record'
require 'models/worklog_issue'
require 'constants'

# Database managment for scheduled issues
class Database
  def self.open(test_db = false)
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: database_path(test_db)
    )
  end

  def self.prepare_database
    self.open
    ActiveRecord::Base.connection.execute(create_table_sql('worklog_issues'))
  end

  def self.prepare_test_database
    self.open(true)
    ActiveRecord::Base.connection.execute(create_table_sql)
  end

  private_class_method def self.database_path(test_db = false)
    table_name = test_db ? 'scheduled_test.sqlite' : 'scheduled.sqlite'
    File.join(Dir.home, Constants::ROOT_FOLDER_NAME, table_name)
  end

  private_class_method def self.create_table_sql
    <<-SQL
      CREATE TABLE IF NOT EXISTS worklog_issues (
        id INTEGER PRIMARY KEY,
        jira_id TEXT NOT NULL,
        description TEXT NOT NULL,
        adjustment_mode INTEGER NOT NULL DEFAULT 0,
        duration TEXT,
        converted_duration INTEGER,
        start_time TEXT,
        date TEXT,
        repeat INTEGER
      )
    SQL
  end
end
