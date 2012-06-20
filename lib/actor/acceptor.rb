# encoding: utf-8
# @author Kadvin, Date: 12-6-1

#
# = The accept test runner
#
require "actor"
require "spi"
require "accept"

module Actor


  class Acceptor < Base
    def initialize(*args)
      super
      @reporter = Accept::Reporter.new("root", "验收测试报告")
      @threads = {}
    end

    ##
    #  Run the accept test cases
    #  |
    #  |-threads
    #  |     |--api_delay_thread_1: worker_api_delay
    #  |     |--api_delay_thread_2: worker_api_delay
    #  |     |--  ......
    #  |     |--api_delay_thread_n: worker_api_delay
    #  |     |--get_indicator_delay_thread_1: worker_get_indicator_delay
    #  |     |--get_indicator_delay_thread_2: worker_get_indicator_delay
    #  |     |--  ......
    #  |     |--get_indicator_delay_thread_n: worker_get_indicator_delay
    #  |     |--probe_tolerance_thread
    #  |     |--threshold_receive_thread
    #  |     |--record_receive_thread
    #  |     |--stability_thread
    ##
    def run(*args)
      server, port = *args
      Spi::Base.site = "http://#{server}:#{port || 8020}/v1"
      @server = Spi::Mo.all(:params=>{:type => :PDMServer}).first
      @reporter.add(:global, "整体报告") do |rpt|
        rpt.add(:start_at, "验收开始时间", Time.now)
        rpt.add(:server_addr, "服务器地址", server)
        rpt.add(:server_up_time, "服务器启动时间", @server.get_indicator(:UpTime).value)
        rpt.add(:server_config, "服务器配置", "2C4G Windows 2008 X86 32") # I should get this info by inspect, instead of hard-code
      end
      @reporter.add take_snapshot(:init_snapshot, "服务器初始快照")
      # how many ApiDelay workers
      if ((count = options[:case_api_delay]) && count > 0 )
        (count - 1).times do |i|
          @threads["api_delay_thread_#{i}".to_sym] = Thread.new do
            Accept::ApiDelay.new(i, 1).run
          end
        end
      end
      # how many GetIndicator workers
      if ((count = options[:case_get_indicator_delay]) && count > 0 )
        (count-1).times do |i|
          @threads["get_indicator_delay_thread_#{i}".to_sym] = Thread.new do
            Accept::GetIndicator.new(i, 1).run
          end
        end
      end

      if (options[:case_probe_tolerance])
        @threads[:probe_tolerance_thread] = Thread.start do
          Accept::ProbeTolerance.new(@reporter).run
        end
      end

      if (options[:case_threshold_receive])
        @threads[:threshold_receive_thread] = Thread.start do
          Accept::ThresholdReceive.new(@reporter).run
        end
      end

      if (options[:case_record_receive])
        @threads[:record_receive_thread] = Thread.start do
          Accept::RecordReceive.new(@reporter).run
        end
      end

      if (options[:case_stability])
        @threads[:stability_thread] = Thread.start do
          Accept::Stability.new(@reporter).run
        end
      end
      @reporter.output
      @threads.each_pair do |name, thread|
        thread.join
      end
    end

    def take_snapshot(name, title)
      Accept::Reporter.new(name, title) do |reporter|
        reporter.add(:snap_at, "时间", Time.now)
        reporter.add(:mo_summary, "管理对象情况") do |rpt|
          %W[NetworkDevice Windows IBMAixServer].each do |type|
            cnt = Spi::Mo.count(:type => type) rescue "Not Supported"
            rpt.add(type, nil, cnt)
          end
        end
        reporter.add(:threshold_rule_summary, "阈值规则情况") do |rpt|
          %W[NetworkDevice Windows IBMAixServer].each do |type|
            cnt = Spi::ThresholdRule.count(:moType => type) rescue "Not Supported"
            rpt.add(type, nil, cnt)
          end
        end
        reporter.add(:record_rule_summary, "记录规则情况") do |rpt|
          %W[NetworkDevice Windows IBMAixServer].each do |type|
            cnt = Spi::RecordRule.count(:moType => type) rescue "Not Supported"
            rpt.add(type, nil, cnt)
          end
        end
      end
    end
  end
end