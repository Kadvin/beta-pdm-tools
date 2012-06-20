# encoding: utf-8
# @author Kadvin, Date: 11-12-27

require "rubygems"
require "active_support/core_ext/array"
require "active_support/ordered_hash"
require "analysis/rule"
require "analysis/rule_set"
require "models/user_task"
require "models/log_record"

module Analysis
  #
  # = The log analysis engine
  #
  # ==analysis files:
  #
  #  # puts all analysed user task to stdout
  #  Engine.analysis(files) do |user_task|
  #    puts user_task.to_json
  #    user_task.log_records.each  do |record|
  #      puts "\t%s" % record.to_json
  #    end
  #  end
  #
  #  # store all analysed user task to db
  #  Engine.analysis(files, :timestamp => '12:00:00,000') do |user_task|
  #    user_task.save!
  #  end
  #
  # ==configure the engine:
  #
  #  Engine.configure do
  #    define_pattern :mo, /mo-pattern/  # can be referred by method: mo_ptn or mo_pattern
  #    define_pattern :engine, /engine-pattern/
  #    define_pattern :mo_with_ip, /mo-ip-pattern/
  #
  #    if_file_like(/file-ptn/) do
  #      log_should_like(/log-ptn-(.*)-(.*)/) do |file, file_no, line_no, md|
  #        record = LogRecord.new(:record_at => md[1], :level => md[2], :thread_name => md[3], :class_name => md[4], :method_name => md[5])
  #        record.content = md[6]
  #        record.file = "Xxxx"
  #        record
  #      end
  #
  #      if_content_like(/Creating #{mo_with_ip_ptn}/) # Creating MO(192.168.10.10)
  #        # 日志的identifier规则至少得有一条，identifier 标识这条日志所属的实际事务，一条日志可能属于多个实际事务(因为一段代码可能被多个事务中调用)
  #        .identified_by('create-mo-#{$1}')               # create-mo-192.168.10.10
  #        # title规则可以没有，如果没有，会直接取日志原始内容(不包括时间，级别，方法，线程等固定配置)
  #        .title_will_be('准备创建MO(#{$1})')             # 准备创建MO(192.168.10.10)
  #        # 只需要为第一个能辨识用户原始任务的日志配置
  #        .origin_task_as('创建MO(#{$1})')                # 创建MO(192.168.10.10)
  #        # 也可以写为如下，直接取title作为用户任务名
  #        #.origin_task_as(:title)                        # 准备创建MO(192.168.10.10)
  #        .ready!                                         # 对创建的规则进行校验
  #
  #      if_content_like(/Created #{mo_with_ip_ptn}/)         # Created MO(192.168.10.10)
  #        .identified_by('create-mo-#{$1}')               # create-mo-192.168.10.10
  #        .title_will_be('已经创建MO(#{$1})')              # 已经创建MO(192.168.10.10)
  #
  #      if_content_like(/Deleting #{mo_with_key_ptn}/).ready! # will throw exception because miss identifier, title expression
  #
  #
  #      if_content_like(/Assigning #{mo_ptn} to #{engine_ptn}/) # Assigning MO(IP : "192.168.10.10", moKey : "aa-bb-cc-dd-ee-ff-gg") to Engine(120.20.20.3)
  #        .title_will_be('开始向引擎(#{$2})分配MO(#{$1})')    # 开始向引擎(120.20.20.3)分配MO(IP : "192.168.10.10")
  #        .identified_by('create-mo-#{$1}')                  # create-mo-192.168.10.10
  #
  #      # below is a connector node
  #      # it has multiple identifiers to connect PS context with SE context
  #      # in ps domain, the mo key is not generated, so the task identifier is: create-mo-IP
  #      # in se domain, they process task by mo key, so the task identifier is: create-mo-KEY
  #      # the connector node can be choose in any log which has two context information both
  #      # I suggest choose Facade class logs
  #      if_content_like(/Assigned #{mo_ptn} to #{engine_ptn/)   # Assigned MO(IP : "192.168.10.10", moKey : "aa-bb-cc-dd-ee-ff-gg") to Engine(120.20.20.3)
  #        .title_will_be('完成向引擎(#{$2})分配MO(#{$1})')    # 完成向引擎(120.20.20.3)分配MO(IP : "192.168.10.10")
  #        .identified_by('create-mo-#{$1}')                  # create-mo-192.168.10.10
  #        .identified_by('create-mo-#{$4}')                  # create-mo-aa-bb-cc-dd-ee-ff-gg
  #
  #    end
  #
  #    if_file_like(/se_commander.log.*/) do
  #      # below node haven't configure any information about the class and method, its more robust against *refactor*
  #      if_content_like(/Assigning #{mo_ptn}/) # Assigning MO(IP : "192.168.10.10", moKey : "aa-bb-cc-dd-ee-ff-gg")
  #        .title_will_be('接收MO(#{$4})')        # 接收MO(aa-bb-cc-dd-ee-ff-gg))
  #        .identified_by('create-mo-#{$4}')        # create-mo-aa-bb-cc-dd-ee-ff-gg
  #
  #      # below demo a log which will be generated in performing multiple original user tasks
  #      #  origin user task 1: create-mo-xxx, which will read mo(xxx)'s property(yyy)
  #      #  origin user task 2: get-mo-xxx-indicator-yyy, which will read mo(xxx)'s property(yyy) directly also
  #      if_content_like(/Read #{property_ptn}}/).with_class(/ResultServiceImpl/).with_method(/getResult/)
  #       .identified_by('create-mo-#{$4}').title_will_be('在创建MO($4)读取属性($5)')
  #       .identified_by('sample-mo-#{$4}-property-#{$5}').title_will_be('读取MO($4)属性($5)')
  #    end
  #  end
  #
  class Engine
    # File Rules is a ordered hash(We will process the file match the prev hash key first) like:
    # /file-pattern-1/ => RuleSet-1{
    #   :name1 => Rule1(title_expression, user_task_proc),
    #   :name2 => Rule2(title_expression, user_task_proc),
    # }
    # /file-pattern-2/ => RuleSet-2{
    #   :name1 => Rule1(title_expression, user_task_proc),
    #   :name2 => Rule2(title_expression, user_task_proc),
    # }
    attr_reader :file_rules
    attr_reader :global_log_pattern, :global_record_proc, :patterns

    def initialize
      @file_rules = ActiveSupport::OrderedHash.new{|hash, file_ptn| hash[file_ptn] =  RuleSet.new(self, file_ptn, global_log_pattern, global_record_proc)}
      @patterns = {}
    end

    ##
    # ==Configure global file log pattern and record proc
    # the proc you provide should accept 3 parameters:
    #  * file name
    #  * file_no: file sequence
    #  * line_no: line number
    #  * match data
    def log_should_like(log_pattern, &block)
      @global_log_pattern = log_pattern
      @global_record_proc = block
    end

    #
    # == configure a rule set for a log file
    # if you need handle rolling files, such as: ps_userpane.log and ps_userpane.log.1
    # then you should provide a regexp which can catch the rolling number as first group: $1
    # we will treat they order as:
    #  * ps_userpane.log.1
    #  * ps_userpane.log.2
    #  * ps_userpane.log
    def if_file_like(file_pattern, &block)
      current_rule_set = rule_set(file_pattern)
      current_rule_set.instance_exec(&block) if block
      current_rule_set.validate!
    end

    def rule_set(file_pattern)
      # convert strict string into file pattern
      file_pattern = /#{file_pattern}/ if file_pattern.is_a? String
      file_rules[file_pattern]
    end
    #
    # 为DSL定义可以引用的Pattern
    #
    #   with_content(/Create #{mo_pattern}/)
    #
    #  需要预先进行mo_pattern的定义，或者叫注册:
    #
    #   define_pattern(:mo, /MO(...)/mx)
    #
    def define_pattern(symbol, regexp)
      patterns[symbol.to_sym] = regexp
    end

    # Support rules can refer pre-defined pattern by name + ptn
    def method_missing(name, *args, &block)
      if( args.empty? && block.nil? && (name.to_s =~ /(.+)(?:_ptn|_pattern)/))
        ptn = patterns[$1.to_sym]
        return ptn if ptn
      end
      super.method_missing(name, *args, &block)
    end

    # == Configure the engine with given block
    # the block is run in the engine instance context
    def configure(&block)
      instance_exec(&block)
    end

    # == Analysis target files
    # and output user_tasks to the given block
    def analysis(*files, &block)
      options = files.extract_options!
      files.flatten!
      files.sort! do |f1, f2|
        pattern_order_of(f1) <=> pattern_order_of(f2)
      end
      records = []
      options[:records] = records
      files.each_with_index do |file, index|
        process(file, index, options, &block)
      end
      # 新算法: 把归属于同一个用户任务的日志串起来
      records.sort!
      user_tasks = [] #{ nil => UserTask.new }
      empty = UserTask.new
      records.each do |record|
        if record.user_task_title
          user_tasks << record.create_user_task
        else
          user_task = user_tasks.detect do |u| 
            u.cover?(record)
          end || empty
          user_task.append record
        end
      end
      begin
        log_records = empty.log_records
        warn "Can't dig out any user task for #{log_records.size} log records\nuse -e path/to/error/file to specify the error output file!"
        warn(UserTask.csv_head)
        user_tasks.each do |task|
          warn task.to_csv + "\t" + task.identifiers.join(",")
          task.log_records.each{|lr| warn(lr.identifiers.join(","))}
        end
        warn("------------")
        log_records.each { |record| warn record.title + "\t" + record.identifiers.join(",") }
        warn("------------")
      end if empty.log_records.any?
      user_tasks.sort! { |t1, t2| t1.start_at <=> t2.start_at }
      user_tasks.each do |user_task|
        user_task.valid? # trigger the before_validation
        block.call(user_task)
      end if block
      user_tasks
    end

    ## ==Process a log file and recognize some LogRecords
    def process(file, index, options = {})
      rule_set = rule_of(file)
      if rule_set.nil?
        warn("Can't find any rule set to process the file: #{file}")
      else
        rule_set.process(file, index, options)
      end
    end

    private

    def pattern_order_of(file)
      patterns = file_rules.keys
      pattern = patterns.detect{|pattern| pattern =~ file}
      return 0 unless pattern
      # 对应的正则表达式在整体的规则中的顺序
      ptn_seq = patterns.index(pattern)
      pattern =~ file
      # 如果文件是滚动生成的，相应的文件表达式应该能捕获到其序号，根据需要还要进行微调
      # 回滚文件不超过100个，都能正确微调
      order = if $1
        ptn_seq * 100 + $1.to_i
      else
        ptn_seq * 100 + 100
      end
      order
    end

    def rule_of(file)
      patterns = file_rules.keys
      pattern = patterns.detect{|pattern| pattern =~ file}
      file_rules[pattern]
    end

    class << self

      #
      # ==Configure the engine
      #  Engine.configure do
      #    # call engine instance method just as inner code, omits explicit instance calls
      #    when_meet(/some-file/)
      #  end
      #
      #def configure(&block)
      #  # the block will be executed in the instance context
      #  instance.configure(&block)
      #end
      delegate :configure, :to => :instance

      ##
      # ==Use the default engine to analysis target files with specified options
      #  Engine.analysis(fil1, file2, :timestamp => "12:00:00,000")
      #def analysis(*files)
      #  instance.analysis(*files)
      #end
      delegate :analysis, :to => :instance

      def instance
        @@instance ||= new
      end
    end
  end

end
