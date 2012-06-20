# @author Kadvin, Date: 11-12-15
#
# = Create User Task
#
class CreateUserTasks < ActiveRecord::Migration
  def up
    self.class.create_table :user_tasks, :options => 'engine MyISAM' do |t|
      t.string :title # origin task title
      t.string :carrier # process/thread names
      t.string :start_at
      t.string :end_at
      t.integer :cost # milliseconds
      t.integer :concurrent # how many other user tasks create with me?
      t.integer :log_records_count
    end
  end

  def down
    self.class.drop_table :user_tasks
  end

  def migrated?
    self.class.connection.select_one("show tables like 'user_tasks'")
  end

  def reset
    self.class.connection.execute("truncate table user_tasks")
  end

  def backup(options = {})
    tag ||= options[:tag]
    tag ||= Time.now.strftime("%Y_%m_%d_%M_%H_%S")
    table = "user_tasks_#{tag}"
    self.class.drop_table table if self.class.connection.select_one("show tables like '#{table}'")
    self.class.connection.execute("rename table user_tasks to #{table}")
  end
end
