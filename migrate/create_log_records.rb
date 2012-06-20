# @author Kadvin, Date: 11-12-15

#
# = Create log records
#
class CreateLogRecords < ActiveRecord::Migration
  def up
    self.class.create_table :log_records, :options => 'engine MyISAM' do |t|
      t.belongs_to :user_task
      t.string :thread_name
      t.string :class_name
      t.string :method_name
      t.string :record_at
      t.string :level
      t.string :file
      t.integer :file_no
      t.integer :line_no
      t.string :title
      t.string :identifiers
    end
  end

  def down
    self.class.drop_table :log_records
  end

  def migrated?
    self.class.connection.select_one("show tables like 'log_records'")
  end

  def reset
    self.class.connection.execute("truncate table log_records")
  end

  def backup(options = {})
    tag ||= options[:tag]
    tag ||= Time.now.strftime("%Y_%m_%d_%M_%H_%S")
    table = "log_records_#{tag}"
    self.class.drop_table table if self.class.connection.select_one("show tables like '#{table}'")
    self.class.connection.execute("rename table log_records to #{table}")
  end
end
