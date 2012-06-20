# @author Kadvin, Date: 11-12-21

require "optparse"
require 'rubygems/user_interaction'

module Pdm
  ##
  # Base class for all Pdm commands.  When creating a new pdm command, define
  # #new, #execute, #arguments, #defaults_str, #description and #usage
  # (as appropriate).  See the above mentioned methods for details.
  #
  # A very good example to look at is Pdm::Commands::FtpCommand
  class Command

    include Gem::UserInteraction

    ##
    # The name of the command.

    attr_reader :command

    ##
    # The options for the command.

    attr_reader :options

    ##
    # The default options for the command.

    attr_accessor :defaults

    ##
    # The name of the command for command-line invocation.

    attr_accessor :program_name

    ##
    # A short description of the command.

    attr_accessor :summary

    def self.common_options
      @common_options ||= []
    end

    def self.add_common_option(*args, &handler)
      Pdm::Command.common_options << [args, handler]
    end

    def self.extra_args
      @extra_args ||= []
    end

    def self.extra_args=(value)
      case value
      when Array
        @extra_args = value
      when String
        @extra_args = value.split
      end
    end

    ##
    # Return an array of extra arguments for the command.  The extra arguments
    # come from the pdm configuration file read at program startup.

    def self.specific_extra_args(cmd)
      specific_extra_args_hash[cmd]
    end

    ##
    # Add a list of extra arguments for the given command.  +args+ may be an
    # array or a string to be split on white space.

    def self.add_specific_extra_args(cmd,args)
      args = args.split(/\s+/) if args.kind_of? String
      specific_extra_args_hash[cmd] = args
    end

    ##
    # Accessor for the specific extra args hash (self initializing).

    def self.specific_extra_args_hash
      @specific_extra_args_hash ||= Hash.new do |h,k|
        h[k] = Array.new
      end
    end

    ##
    # Initializes a generic pdm command named +command+.  +summary+ is a short
    # description displayed in `pdm help commands`.  +defaults+ are the default
    # options.  Defaults should be mirrored in #defaults_str, unless there are
    # none.
    #
    # When defining a new command subclass, use add_option to add command-line
    # switches.
    #
    # Unhandled arguments (pdm names, files, etc.) are left in
    # <tt>options[:args]</tt>.

    def initialize(command, summary=nil, defaults={})
      @command = command
      @summary = summary
      @program_name = "pdm #{command}"
      @defaults = defaults
      @options = defaults.dup
      @option_groups = Hash.new { |h,k| h[k] = [] }
      @parser = nil
      @when_invoked = nil
    end

    ##
    # True if +long+ begins with the characters from +short+.

    def begins?(long, short)
      return false if short.nil?
      long[0, short.length] == short
    end

    ##
    # Override to provide command handling.
    #
    # #options will be filled in with your parsed options, unparsed options will
    # be left in <tt>options[:args]</tt>.
    #

    def execute
      raise Pdm::Exception, "generic command has no actions"
    end

    ##
    # Get a single optional argument from the command line.  If more than one
    # argument is given, return only the first. Return nil if none are given.

    def get_one_optional_argument
      args = options[:args] || []
      args.first
    end

    ##
    # Override to provide details of the arguments a command takes.  It should
    # return a left-justified string, one argument per line.
    #
    # For example:
    #
    #   def usage
    #     "#{program_name} FILE [FILE ...]"
    #   end
    #
    #   def arguments
    #     "FILE          name of file to find"
    #   end

    def arguments
      ""
    end

    ##
    # Override to display the default values of the command options. (similar to
    # +arguments+, but displays the default values).
    #
    # For example:
    #
    #   def defaults_str
    #     --no-pdms-first --no-all
    #   end

    def defaults_str
      ""
    end

    ##
    # Override to display a longer description of what this command does.

    def description
      nil
    end

    ##
    # Override to display the usage for an individual pdm command.
    #
    # The text "[options]" is automatically appended to the usage text.

    def usage
      program_name
    end

    ##
    # Display the help message for the command.

    def show_help
      parser.program_name = usage
      say parser
    end

    ##
    # Invoke the command with the given list of arguments.

    def invoke(*args)
      handle_options args

      if options[:help] then
        show_help
      elsif @when_invoked then
        @when_invoked.call options
      else
        execute
      end
    end

    ##
    # Call the given block when invoked.
    #
    # Normal command invocations just executes the +execute+ method of the
    # command.  Specifying an invocation block allows the test methods to
    # override the normal action of a command to determine that it has been
    # invoked correctly.

    def when_invoked(&block)
      @when_invoked = block
    end

    ##
    # Add a command-line option and handler to the command.
    #
    # See OptionParser#make_switch for an explanation of +opts+.
    #
    # +handler+ will be called with two values, the value of the argument and
    # the options hash.
    #
    # If the first argument of add_option is a Symbol, it's used to group
    # options in output.  See `pdm help list` for an example.

    def add_option(*opts, &handler) # :yields: value, options
      group_name = Symbol === opts.first ? opts.shift : :options

      @option_groups[group_name] << [opts, handler]
    end

    ##
    # Remove previously defined command-line argument +name+.

    def remove_option(name)
      @option_groups.each do |_, option_list|
        option_list.reject! { |args, _| args.any? { |x| x =~ /^#{name}/ } }
      end
    end

    ##
    # Merge a set of command options with the set of default options (without
    # modifying the default option hash).

    def merge_options(new_options)
      @options = @defaults.clone
      new_options.each do |k,v| @options[k] = v end
    end

    ##
    # True if the command handles the given argument list.

    def handles?(args)
      begin
        parser.parse!(args.dup)
        return true
      rescue
        return false
      end
    end

    ##
    # Handle the given list of arguments by parsing them and recording the
    # results.

    def handle_options(args)
      args = add_extra_args(args)
      @options = @defaults.clone
      parser.parse!(args)
      @options[:args] = args
    end

    ##
    # Adds extra args from ~/.pdmrc

    def add_extra_args(args)
      result = []

      s_extra = Pdm::Command.specific_extra_args(@command)
      extra = Pdm::Command.extra_args + s_extra

      until extra.empty? do
        ex = []
        ex << extra.shift
        ex << extra.shift if extra.first.to_s =~ /^[^-]/
        result << ex if handles?(ex)
      end

      result.flatten!
      result.concat(args)
      result
    end

    private

    ##
    # Create on demand parser.

    def parser
      create_option_parser if @parser.nil?
      @parser
    end

    def create_option_parser
      @parser = OptionParser.new

      @parser.separator nil
      regular_options = @option_groups.delete :options

      configure_options "", regular_options

      @option_groups.sort_by { |n,_| n.to_s }.each do |group_name, option_list|
        @parser.separator nil
        configure_options group_name, option_list
      end

      @parser.separator nil
      configure_options "Common", Pdm::Command.common_options

      unless arguments.empty?
        @parser.separator nil
        @parser.separator "  Arguments:"
        arguments.split(/\n/).each do |arg_desc|
          @parser.separator "    #{arg_desc}"
        end
      end

      @parser.separator nil
      @parser.separator "  Summary:"
      wrap(@summary, 80 - 4).split("\n").each do |line|
        @parser.separator "    #{line.strip}"
      end

      if description then
        formatted = description.split("\n\n").map do |chunk|
          wrap chunk, 80 - 4
        end.join "\n"

        @parser.separator nil
        @parser.separator "  Description:"
        formatted.split("\n").each do |line|
          @parser.separator "    #{line.rstrip}"
        end
      end

      unless defaults_str.empty?
        @parser.separator nil
        @parser.separator "  Defaults:"
        defaults_str.split(/\n/).each do |line|
          @parser.separator "    #{line}"
        end
      end
    end

    def configure_options(header, option_list)
      return if option_list.nil? or option_list.empty?

      header = header.to_s.empty? ? '' : "#{header} "
      @parser.separator "  #{header}Options:"

      option_list.each do |args, handler|
        dashes = args.select { |arg| arg =~ /^-/ }
        @parser.on(*args) do |value|
          handler.call(value, @options)
        end
      end

      @parser.separator ''
    end

    ##
    # Wraps +text+ to +width+

    def wrap(text, width) # :doc:
      text.gsub(/(.{1,#{width}})( +|$\n?)|(.{1,#{width}})/, "\\1\\3\n")
    end

    # ----------------------------------------------------------------
    # Add the options common to all commands.

    add_common_option('-h', '--help',
                      'Get help on this command') do |value, options|
      options[:help] = true
    end

    add_common_option('-V', '--[no-]verbose',
                      'Set the verbose level of output') do |value, options|
      # Set us to "really verbose" so the progress meter works
      if Pdm.configuration.verbose and value then
        Pdm.configuration.verbose = 1
      else
        Pdm.configuration.verbose = value
      end
    end

    add_common_option('-q', '--quiet', 'Silence commands') do |value, options|
      Pdm.configuration.verbose = false
    end

    # Backtrace and config-file are added so they show up in the help
    # commands.  Both options are actually handled before the other
    # options get parsed.

    add_common_option('--config-file FILE',
                      'Use this config file instead of default') do
    end

    add_common_option('--backtrace',
                      'Show stack backtrace on errors') do
    end

    add_common_option('--debug',
                      'Turn on Ruby debugging') do
    end

    HELP = <<-HELP
  Pdm is a quick tools for BetaSoft PDM sampling engine.  This is a
  basic help message containing pointers to more information.

    Usage:
      pdm -h/--help
      pdm -v/--version
      pdm command [arguments...] [options...]

    Further help:
      pdm help commands            list all 'pdm' commands
      pdm help examples            show some examples of usage
      pdm help <COMMAND>           show help on COMMAND
                                     (e.g. 'pdm help install')
    Further information:
      http://pdm.betasoft.net
    HELP
  end

  ##
  # This is where Commands will be placed in the namespace
  #
  module Commands
  end
end
