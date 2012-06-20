# encoding: utf-8
# @author Kadvin, Date: 11-12-27

require "ostruct"
#
# = A rule
#
module Analysis

  #
  # A engine rule, has such attributes:
  #
  # Filters:
  #  * class_ptn : for class name
  #  * method_ptn : for method name
  #  * level_ptn : for level value
  #  * thread_ptn : for thread name
  # Expressions:
  #  * identifier_exp : identifier exp(s)
  #  * title_exp : title exp(s))
  #  * task_exp : original user task exp
  class Rule
    attr_reader :name, :engine
    attr_accessor :level_ptn, :class_ptn, :method_ptn, :thread_ptn, :content_ptn, :title_exp, :task_exp

    def initialize(engine, name)
      @engine = engine
      @name = name
    end

    # support pattern access
    # when call rule.xxx_ptn, rule.xxx_pattern will cal to engine.xxx_ptn
    delegate :method_missing, :to => :engine

    def level_should_match(level_pattern)
      self.level_ptn = level_pattern
      self
    end

    def class_should_match(class_pattern)
      self.class_ptn = class_pattern
      self
    end

    def method_should_match(method_pattern)
      self.method_ptn = method_pattern
      self
    end

    def thread_should_match(thread_pattern)
      self.thread_ptn = thread_pattern
      self
    end

    def content_should_match(content_pattern)
      self.content_ptn = content_pattern
      self
    end

    def identified_by(identifier_exp)
      self.identifier_exps << identifier_exp
      self
    end

    def title_will_be(title_exp)
      self.title_exp = title_exp
      self
    end

    def original_task_as(task_exp)
      self.task_exp = task_exp
      self
    end

    def validate!
      raise "Miss content pattern! " unless self.content_ptn
      raise "Miss identifier expressions! " if self.identifier_exps.empty?
      raise "Miss title expression! " if self.title_exp.nil?
    end
    alias_method :ready!, :validate!

    def match?(record)
      return nil if level_ptn and !(level_ptn =~ record.level)
      return nil if class_ptn and !(class_ptn =~ record.class_name)
      return nil if method_ptn and !(method_ptn =~ record.method_name)
      return nil if thread_ptn and !(thread_ptn =~ record.thread_name)
      content_ptn.match(record.content)
    end

    def process(record, match_data, options = {})
      # return the user-readable title of the content
      identifier_exps.each { |exp| record.add_identifier eval_exp(record, exp, match_data) }
      record.title = eval_exp(record, self.title_exp, match_data)
      record.user_task_title = eval_exp(record, self.task_exp, match_data)
      record
    end

    def identifier_exps
       @identifier_exps ||= []
    end

    private
    # convert the exp
    def eval_exp(record, exp, md)
      case exp
        when String
          # 将对上下文 $1, $2 的依赖 转换为对 match data的显性化引用
          # 如: exp = '/Create #{$1}/' -> '/Create #{md[1]}/'
          exp = exp.gsub /\$(\d+)/, 'md[\1]'
          eval("\"#{exp}\"")
        when Symbol #such as :title, means title of the record
          record.send(exp)
        when Proc
          exp.call(record)
        else
          nil
      end
    end

  end

end
