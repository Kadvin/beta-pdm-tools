# @author Kadvin, Date: 11-12-22

require "active_support/core_ext"
require "active_support/core_ext/array"
require "logger"
require "actor"
#
# = The basic actor
#
module Actor
  if not const_defined? :LOGGER
    Dir.mkdir("log") unless File.exist?("log")
    LOGGER = Logger.new("log/pdm.log", 'daily')
    LOGGER.formatter = proc { |severity, datetime, progname, msg|
      "%-5s %s %s\n" % [severity, datetime.strftime("%H:%M:%S"), msg]
    }
  end

  class Base

    attr_accessor :options

    def initialize(*args)
      @options = args.extract_options!
    end

    def logger;
      LOGGER
    end

    delegate :debug, :to => :logger
    delegate :info, :to => :logger
    delegate :error, :to => :logger
    delegate :fatal, :to => :logger

    protected
    def establish!
      require "active_record"
      options[:host] = options.delete(:server)
      options[:password] = options.delete(:passwd)
      ::ActiveRecord::Base.establish_connection(options)
      yield
    end

    def read_file_or_stdin(file, max_time = 2)
      if file
        IO.read(file)
      else
        begin
          timeout(max_time) do
            t = Thread.new { $stdin.read }
            t.value
          end # read from stdio for 10 seconds
        rescue Timeout::Error
          raise "You should specify the input file as parameter or IO input!"
          #IO.read("ips.txt")
        end
      end
    end
  end
end
