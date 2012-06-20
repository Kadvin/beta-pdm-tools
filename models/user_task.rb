# encoding: utf-8
# @author Kadvin, Date: 11-12-15

require "active_record"
#
# = The user task
#

class UserTask < ActiveRecord::Base
  has_many :log_records, :dependent => :destroy, :order => :start_at

  before_validation :fill_end_timestamp, :calculate_cost

  NAMES = %w[title carrier start_at end_at cost concurrent]

  def concurrent_with?(another)
    another.start_at.between?(self.start_at, self.end_at) or
        another.end_at.between?(self.start_at, self.end_at)
  end

  def identifiers
    @identifiers ||= []
  end

  # ==Append a log record to the user task
  def append(log_record)
    self.log_records << log_record
    log_record.identifiers.each do |id|
      self.identifiers << id if not self.identifiers.include? id
    end
  end

  # ==Judge a log record belongs to the user task
  def cover?( log_record )
    !(self.identifiers & log_record.identifiers).empty?
  end

  def to_csv(separator = "\t")
    NAMES.map do |attr|
      value = self.read_attribute(attr)
      value = value.gsub("\t"," ") if value.is_a? String
      value = value.gsub("\n"," ") if value.is_a? String
      value
    end.join(separator)
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
        attributes[name] = columns[index]
      end
      new attributes
    end

  end

  def to_s; title end

  def output_as_csv(out = $stdout)
    out.puts to_csv
    log_records.sort!
    log_records.each{|record| out.puts record.to_csv}
    out.puts

  end

  def <=>(another)
    self.cost <=> another.cost
  end

  private
  def fill_end_timestamp
    self.end_at = self.log_records.last.record_at if not self.log_records.empty?
  end

  def calculate_cost
    return if start_at.nil? or end_at.nil?
    self.cost = absolute(end_at) - absolute(start_at)
  end

  def absolute(origin)
    /(\d{2}):(\d{2}):(\d{2}),(\d{3})/ =~ origin
    $4.to_i + $3.to_i * 1000 + $2.to_i * 60*1000 + $1.to_i * 60*60*1000
  end
end

# Extends the String with a between? function
String.class_eval do
  def between?(s1, s2)
    self >= s1 && self <= s2
  end
end
