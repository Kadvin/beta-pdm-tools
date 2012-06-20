# @author Kadvin, Date: 11-12-27

require "active_support"
require "analysis/line"
#
# = A set of rules service for one file
#
module Analysis
  class RuleSet < ActiveSupport::OrderedHash
    attr_reader :file_ptn, :log_ptn, :record_proc, :engine

    def initialize(the_engine, file_ptn, log_ptn, record_proc)
      super(){ |hash, key| hash[key] = Rule.new(engine, key) }
      @engine = the_engine
      @file_ptn = file_ptn
      @log_ptn = log_ptn
      @record_proc = record_proc
      @counter = 0
    end

    delegate :method_missing, :to => :engine

    def log_should_like(log_pattern, &block)
      warn "global log pattern: %s is override by %s" % [@log_ptn, log_pattern] if @log_ptn
      @log_ptn = log_pattern
      # How to create the log record from log pattern
      # the record proc accept a MatchData and line_no as input
      #   output a log-record as output
      @record_proc = block
    end

    # ==Define a rule
    alias_method :rule, :[]

    ##
    # Call this method will create a rule
    # because I think rule's content are different with each other
    #
    def if_content_like(ptn, name = nil, &block)
      name ||= "rule-#{@counter += 1}"
      rule = self[name]
      rule.content_ptn = ptn
      begin
        rule.instance_exec(&block)
        rule.validate!
      end if block
      rule
    end

    def exist_rule(name, &block)
      rule = self[name]
      raise "Can't find any exist rule with name = %s" % name unless rule
      begin
        rule.instance_exec(&block)
        rule.validate!
      end if block
      rule
    end

    def validate!
      raise "The general log pattern of this rule set should be configured!" unless log_ptn
    end

    # ==Process the log file to find any covered log records
    def process(file, file_no, options = {})
      #
      # 可能会遇到跨多行的日志记录
      # 为了处理这种情况，采用的算法是：
      #
      # 当遇到符合行格式的日志时，并不立刻处理该行日志，而是延迟等遇到下一个符合格式的日志时
      # 中间遇到不符合格式的日志行时，直接向预留的行中追加数据
      #
      line = nil # 正在被处理的文件行,行号，相应的匹配表达式
      File.open(file, "r:UTF-8").each_with_index do |log, line_no|
        md = log_ptn.match(log)
        if md
          process_line(line, options) if line
          line = Line.new(file, file_no, log, line_no, md)
        else
          line.append log if line # maybe they are no
        end
      end
      process_line(line, options) if line # Process the last line
    end

    def process_line(line, options)
      line.rematch_on_change!(log_ptn)
      record = record_proc.call(line)
      unless record
        warn("Failed to create log record for recognized %s" % line)
        return
      end

      if options[:timestamp] and (record.record_at < options[:timestamp])
        # warn("Skip: %s" % line)
        return
      end

      rule, md = nil, nil
      # use rule to measure record
      self.values.each do |r|
        md = r.match?(record)
        if not md.nil?
          rule = r
          break
        end
      end
      if rule

        rule.process(record, md, options)
        options[:records] << record
      else
        #warn("Can't find any rule for %s" % line)
      end

    end
  end
end
