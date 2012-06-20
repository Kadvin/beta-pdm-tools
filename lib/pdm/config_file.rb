##
# Pdm::ConfigFile options and pdm command options from ~/.pdmrc.
#
# ~/.pdmrc is a YAML file that uses strings to match pdm command arguments and
# symbols to match Pdm options.
#
# Pdm command arguments use a String key that matches the command name and
# allow you to specify default arguments:
#
#   ftp: -s 20.0.9.111 -p 8020 -u server --passwd server
#   telnet: -s 20.0.9.111 -p 8020 -u administrator --passwd beta123
#
# You can use <tt>pdm:</tt> to set default arguments for all commands.
#
# Pdm options use symbol keys.  Valid options are:
#
# +:backtrace+:: See #backtrace
# +:benchmark+:: See #benchmark
# +:sources+:: Sets Gem::sources
# +:verbose+:: See #verbose
require "active_support/core_ext/hash"
module Pdm

  class ConfigFile

    DEFAULT_BACKTRACE = false
    DEFAULT_BENCHMARK = false
    DEFAULT_VERBOSITY = true
    system_config_path = begin
      require 'etc.so'
       Etc.sysconfdir
    rescue LoadError, NoMethodError
      '/etc'
    end

    ##
    # For Ruby packagers to set configuration defaults.  Set in
    # rubygems/defaults/operating_system.rb

    OPERATING_SYSTEM_DEFAULTS = {}

    ##
    # For Ruby implementers to set configuration defaults.  Set in
    # rubygems/defaults/#{RUBY_ENGINE}.rb

    PLATFORM_DEFAULTS = {}

    SYSTEM_WIDE_CONFIG_FILE = File.join system_config_path, '.pdmrc'

    ##
    # List of arguments supplied to the config file object.

    attr_reader :args

    ##
    # True if we print backtraces on errors.

    attr_writer :backtrace

    ##
    # True if we are benchmarking this run.

    attr_accessor :benchmark


    ##
    # Verbose level of output:
    # * false -- No output
    # * true -- Normal output
    # * :loud -- Extra output

    attr_accessor :verbose

    ##
    # Create the config file object.  +args+ is the list of arguments
    # from the command line.
    #
    # The following command line options are handled early here rather
    # than later at the time most command options are processed.
    #
    # <tt>--config-file</tt>, <tt>--config-file==NAME</tt>::
    #   Obviously these need to be handled by the ConfigFile object to ensure we
    #   get the right config file.
    #
    # <tt>--backtrace</tt>::
    #   Backtrace needs to be turned on early so that errors before normal
    #   option parsing can be properly handled.
    #
    # <tt>--debug</tt>::
    #   Enable Ruby level debug messages.  Handled early for the same reason as
    #   --backtrace.

    def initialize(arg_list)
      @config_file_name = nil
      need_config_file_name = false

      arg_list = arg_list.map do |arg|
        if need_config_file_name then
          @config_file_name = arg
          need_config_file_name = false
          nil
        elsif arg =~ /^--config-file=(.*)/ then
          @config_file_name = $1
          nil
        elsif arg =~ /^--config-file$/ then
          need_config_file_name = true
          nil
        else
          arg
        end
      end.compact

      @backtrace = DEFAULT_BACKTRACE
      @benchmark = DEFAULT_BENCHMARK
      @verbose = DEFAULT_VERBOSITY

      operating_system_config = Marshal.load Marshal.dump(OPERATING_SYSTEM_DEFAULTS)
      platform_config = Marshal.load Marshal.dump(PLATFORM_DEFAULTS)
      system_config = load_file SYSTEM_WIDE_CONFIG_FILE
      user_config = load_file config_file_name.dup.untaint

      @hash = operating_system_config.merge platform_config
      @hash = @hash.merge system_config
      @hash = @hash.merge user_config
      @hash.stringify_keys!

      # HACK these override command-line args, which is bad
      @backtrace = @hash['backtrace'] if @hash.key? 'backtrace'
      @benchmark = @hash['benchmark'] if @hash.key? 'benchmark'
      @verbose = @hash['verbose'] if @hash.key? 'verbose'
      handle_arguments arg_list
    end


    def load_file(filename)
      return {} unless filename and File.exists?(filename)
      begin
        require 'yaml'
        YAML.load(File.read(filename))
      rescue ArgumentError
        warn "Failed to load #{config_file_name}"
      rescue Errno::EACCES
        warn "Failed to load #{config_file_name} due to permissions problem."
      end or {}
    end

    # True if the backtrace option has been specified, or debug is on.
    def backtrace
      @backtrace or $DEBUG
    end

    # The name of the configuration file.
    def config_file_name
      @config_file_name || Pdm.config_file
    end

    # Delegates to @hash
    def each(&block)
      hash = @hash.dup
      hash.delete :verbose
      hash.delete :benchmark
      hash.delete :backtrace

      yield :verbose, @verbose
      yield :benchmark, @benchmark
      yield :backtrace, @backtrace

      yield 'config_file_name', @config_file_name if @config_file_name

      hash.each(&block)
    end

    # Handle the command arguments.
    def handle_arguments(arg_list)
      @args = []

      arg_list.each do |arg|
        case arg
          when /^--(backtrace|traceback)$/ then
            @backtrace = true
          when /^--bench(mark)?$/ then
            @benchmark = true
          when /^--debug$/ then
            $DEBUG = true
          else
            @args << arg
        end
      end
    end

    # Really verbose mode gives you extra output.
    def really_verbose
      case verbose
        when true, false, nil then
          false
        else
          true
      end
    end

    # to_yaml only overwrites things you can't override on the command line.
    def to_yaml # :nodoc:
      yaml_hash = {}
      yaml_hash[:backtrace] = @hash.key?(:backtrace) ? @hash[:backtrace] :
          DEFAULT_BACKTRACE
      yaml_hash[:benchmark] = @hash.key?(:benchmark) ? @hash[:benchmark] :
          DEFAULT_BENCHMARK
      yaml_hash[:verbose] = @hash.key?(:verbose) ? @hash[:verbose] :
          DEFAULT_VERBOSITY

      keys = yaml_hash.keys.map { |key| key.to_s }
      keys << 'debug'
      re = Regexp.union(*keys)

      @hash.each do |key, value|
        key = key.to_s
        next if key =~ re
        yaml_hash[key.to_s] = value
      end

      yaml_hash.to_yaml
    end

    # Writes out this config file, replacing its source.
    def write
      require 'yaml'
      open config_file_name, 'w' do |io|
        io.write to_yaml
      end
    end

    # Return the configuration information for +key+.
    def [](key)
      @hash[key.to_s]
    end

    # Set configuration option +key+ to +value+.
    def []=(key, value)
      @hash[key.to_s] = value
    end

    def ==(other) # :nodoc:
      self.class === other and
          @backtrace == other.backtrace and
          @benchmark == other.benchmark and
          @verbose == other.verbose and
          @hash == other.hash
    end

    protected

    attr_reader :hash

  end

end
