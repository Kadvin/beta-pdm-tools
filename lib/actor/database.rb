# encoding: utf-8
# @author Kadvin, Date: 11-12-22

require "actor"
require "active_record"

module Actor
  #
  # = The database actor
  #
  class Database < Base
    attr_reader :options

    # ==Execute db migration tasks
    # pdm database migrate up|down|reset PATH/TO/STEP1 PATH/TO/STEP2
    # task: up/down/reset/backup
    def migrate(task, *step_files)
      step_files = begin
        Dir[File.join(File.dirname(__FILE__),"../../migrate/*.rb")]
      end if step_files.empty?
      establish! do
        step_files.each do |step_file|
          require step_file
          File.basename(step_file) =~ /(.*)\.rb$/
          migration = $1.camelize.constantize
          step = migration.new
          case task.to_s
            when "up"
              step.up unless step.migrated?
            when "reset"
              step.reset if step.migrated?
            when "down"
              step.down if step.migrated?
            when "backup"
              step.backup(options) if step.migrated?
            else
              raise "Unsupported sub command: #{task}"
          end
        end
      end
    end

    # ==Import analysis result from result file
    # pdm database import ANALYSIS/RESULT
    def import(*files)
      require "models/user_task"
      require "models/log_record"
      require "timeout"
      establish! do
        unless( files.empty? )
          files.each do |file|
            puts "Loading %s" % file
            File.open(file, "r:utf-8") do |stream|
              import_from stream
            end
          end
        else
          begin
            require "stringio"
            str = Timeout::timeout(10) {
              $stdin.set_encoding("utf-8")
              $stdin.read # read as utf-8, ensured by top of this file comments
            }
            puts "Loading from stdin"
            import_from StringIO.new(str,"r:utf-8")
          rescue Timeout::Error
            raise "You should specify several import file"
          end
        end
      end
    end

    ##
    # ==Validate some tables
    # pdm database validate user_tasks -c "count(0) == 500" -c "avg(cost) <= 60" -c "max(cost) < 100" -c "max(concurrent) > 10"
    def validate(table)
      establish! do
        options[:conditions].each do |cond|
          validate! table, cond
        end
      end
    end

    protected
    def validate!(table, condition)
      left, operation, right = condition.split /(==|!=|<=|>=|=|>|<)/
      raise %Q{Unsupported condition: `%s`, it should be formed like `expression operator value`,
            expression is a sql expression against the target table, such as avg(cost), max(value), count(0), sum(int)
            and operator is one of follow: =,==,>,<,>=,<=,!=,
            the value should be simple value (we do not support another expression now), such as 1000 } % condition unless right
      value = ::ActiveRecord::Base.connection.select_value("select %s from %s" % [left, table])
      operation = "==" if operation == "="
      exp = "%s %s %s" % [value, operation, right]
      info "Evaluate expression: %s" % exp
      result = eval(exp)
      raise "`%s` validate failed against %s, actual value is %s" % [condition, table, value.to_s] unless result
    end

    def import_from(input)
      current_user_task = nil
      input.each_line do |line|
        if line.blank? # meet a empty line, means a
          puts "Save a user task %s" % current_user_task
          current_user_task.save!
          current_user_task = nil
        else
          if (UserTask.match?(line))
            current_user_task = UserTask.from_csv(line)
          elsif LogRecord.match?(line)
            raise "There should be a user task" if current_user_task.nil?
            current_user_task.log_records << LogRecord.from_csv(line)
          else
            raise "Unknown row format, it should be a user task or a log records:\n" + line
          end
        end
      end
    end
  end
end
