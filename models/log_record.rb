# encoding: utf-8

# @author Kadvin, Date: 11-12-7

require "active_record"
#
# = The Record parsed from the Log
#
# have such properties:
#  * process_name
#  * thread
#  * class_name
#  * method_name
#  * record_at
#  * file_no
#  * line_no
#  * content
#  * user_task
#  * title
#  * raw_identifiers
#
class LogRecord < ActiveRecord::Base
  belongs_to :user_task, :counter_cache => true
  attr_accessor :line, :content, :user_task_title
  NAMES = %w[file thread_name class_name method_name record_at level file_no
       line_no title identifiers]

  serialize :identifiers, Array

  def to_s;
    title
  end

  def to_csv(separator = "\t")
    NAMES.map do |attr|
      value = self.read_attribute(attr)
      value = value.join(",")  if value.is_a?(Array)
      value = value.gsub("\t"," ") if value.is_a? String
      value = value.gsub("\n"," ") if value.is_a? String
      value
    end.join(separator)
  end

  def add_identifier(identifier)
    self.identifiers ||= []
    self.identifiers << identifier.upcase
  end

  # Get the log record's identifier
  def identifier
    self.identifiers.first
  end

  def create_user_task
    UserTask.new do |t|
      t.title = user_task_title
      t.carrier = "%s/%s" % [file, thread_name]
      t.start_at = record_at
      t.append(self)
    end
  end

  class << self
    def match?(line)
      line.count("\t") == (NAMES.size - 1)
    end

    def csv_head(separator = "\t")
      NAMES.join(separator)
    end

    def from_csv(line, separator = "\t")
      columns = line.split(separator)
      attributes = {}
      NAMES.each_with_index do |name, index|
        value = columns[index]
        value = (name == "identifiers") ? value.split(",") : value
        attributes[name] = value
      end
      new attributes
    end
  end

  def <=>(another)
    r = self.record_at <=> another.record_at
    if (r == 0) # the same timestamp
                # different process
      if self.file != another.file
        self.file_no <=> another.file_no
      else
        self.line_no <=> another.line_no
      end
    end
    r
  end

  def as_same_identifier(another)
    !(self.identifiers & another.identifiers).empty?
  end

  def to_ctx
    "%s: file=`%s`,thread=`%s`,identifiers=`%s`" %
        [title, file, thread_name, identifiers.join(",")]
  end

end