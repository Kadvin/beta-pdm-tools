# encoding: utf-8
# @author Kadvin, Date: 12-6-4
require "accept"
#
# = Base accept case worker
#
module Accept
  class Worker
    @@users = %W[ZhangSan LiSi YangWu ZhouLiu ZhengQi WangBa]
    @@worker_mutex = Mutex.new
    attr_accessor :rounds
    attr_reader :name, :seq, :delay

    def initialize(seq, delay)
      @seq = seq
      @name = @@users[seq]
      @reporter = Reporter.new("#{self.class.name}##{seq}", @name)
      @delay = delay # delay between operations
      @reporter.add(:delay, "操作间隔", delay)

      # create -> {:total => t, :success => s, :failed => f,
      #            :avg => a, :max => max, :min => min,
      #            :over_total => ot, :over_avg => oa, :over_max => omax, :over_min => omin}
      @stats = Hash.new { |hash, key| hash[key.to_sym] = Stat.new }
      self.rounds = 3
    end

    # make the worker run
    def run()
      rounds.times do |i|
        round(i+1)
      end
      #$stderr.puts "#{name} Finished!\n"
      #below codes is used to output report
      output()
    end

    #
    # Test the operation a round
    #
    def round(round_number)
      start_at = Time.now
      @operations.each_pair do |name, operation|
        stat = @stats[name]
        begin
          op_at = Time.now
          #$stderr.puts "Round##{round_number} #{name} \n"
          operation.call
          stat.succeed(Time.now - op_at)
        rescue
          report_error $!
          stat.failed(Time.now - op_at)
        end
        #$stderr.puts "Sleep %d seconds..." % @delay
        sleep @delay
      end
      @reporter.add(:duration, "操作时长", "%.2f(s)" % (Time.now - start_at))
    end

    def output
      @@worker_mutex.synchronize do
        Reporter.report do
          @operations.each_pair do |name, op|
            @reporter.add(name, nil) do |rpt|
              stat = @stats[name]
              rpt.add(:counts, "执行次数", "总数%d次，成功%d次，失败%d次" % [stat.total, stat.success, stat.fails])
              rpt.add(:cost, "耗时统计", "平均=%.2f(s), 最长=%.2f(s), 最短=%.2f(s)" % [stat.avg, stat.max, stat.min])
              rpt.add(:over, "超时统计", "%d次超时, 平均超时=%.2f(s), 最长超时=%.2f(s), 最短超时=%.2f(s)" %
                  [stat.over_total, stat.over_avg, stat.over_max, stat.over_min])
            end
          end
          @reporter.output($stdout, 2)
        end
      end
    end

    def report_error(error)
      $stderr.puts error
      $stderr.puts error.response.body if error.is_a?(ActiveResource::ClientError)
    end
  end
end
