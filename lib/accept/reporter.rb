require "monitor"

module Accept
  class Reporter
    @@global_monitor = Monitor.new("Global-Reporter-Monitor")

    attr_reader :name, :title, :value, :children
    attr_accessor :parent

    def initialize(name, title = name, value = nil, &block)
      @name, @title = name, title
      @title ||= @name
      @value = value || block
      @children = {}
    end

    def add(name_or_child, title = nil, value = nil, &block)
      if (name_or_child.is_a? Reporter)
        @children[name_or_child.name] = name_or_child
      else
        child = Reporter.new(name_or_child, title, value, &block)
        child.parent = self
        add(child)
      end
    end

    def output(target = $stdout, indent = 1)
      self.class.report do
        target.puts("#{"=" * indent}#{self.title}")
        if value.is_a? Proc
          #target.puts
          value.call(self)
        else
          target.puts("  #{value}") unless value.blank?
        end
        target.puts
        if (children)
          children.each_pair do |name, child|
            child.output(target, indent + 1)
          end
        end
      end
    end

    class << self
      #
      # ==Acquire the global output monitor and report to the stream
      #
      # I'm use a simple way to synchronize the output: global monitor
      # actually, if there are multiple output stream, then the monitor should be a stream related one
      # the caller should report as:
      #
      #  Reporter.report(stream) do
      #    #use the stream to report
      #  end
      def report
        @@global_monitor.synchronize do
          yield
        end
      end
    end
  end
end
