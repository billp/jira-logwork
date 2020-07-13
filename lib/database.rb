# frozen_string_literal: true

require 'sqlite3'
require 'active_record'
require 'models/worklog_issue'
require 'constants'

# Database managment for scheduled issues
class Database
  def self.prepare_database
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: database_path
    )

    ActiveRecord::Base.connection.execute(create_table_sql)
  end

  private_class_method def self.database_path
    File.join(Dir.home, Constants::ROOT_FOLDER_NAME, 'scheduled.sqlite')
  end

  private_class_method def self.create_table_sql
    <<-SQL
      CREATE TABLE IF NOT EXISTS worklog_issues (
        id INTEGER PRIMARY KEY,
        jira_id TEXT NOT NULL,
        description TEXT NOT NULL,
        adjustment_mode INTEGER NOT NULL,
        duration TEXT,
        converted_duration INTEGER,
        start_time TEXT,
        date TEXT,
        repeat INTEGER
      )
    SQL
  end
end
