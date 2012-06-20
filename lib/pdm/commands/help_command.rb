require 'pdm/command'
require 'pdm/generic_option'

class Pdm::Commands::HelpCommand < Pdm::Command

  # :stopdoc:
  EXAMPLES = <<-EOF
    Examples:
      TO accomplish a pressure test, you need fetch a fresh pdm release, and deployed it to the target server ...

      1. Get pdm release through FTP
            pdm ftp get PATH/TO/RELEASE --to LOCAL/DIR -s FTP_IP -p FTP_PORT --user ACCOUNT --passwd PASSWORD
      2. Deployed it to a server
            pdm ftp put LOCAL/DIR/RELEASE --to PATH/TO/DEPLOY -s FTP_IP -p FTP_PORT  --user ACCOUNT --passwd PASSWORD
      3. Start the pdm server
            pdm telnet "unzip pdm.zip" -s SERVER_IP -p TELNET_PORT
            pdm telnet "start pdm.exe" -s SERVER_IP -p TELNET_PORT
            pdm telnet  -s SERVER_IP -p TELNET_PORT < PATH/TO/SCRIPT
      4. Activate all the probe packages
      4.1 List all available probe packages by userpane
            pdm userpane list probe_packages --filter identify -s SERVER_IP -p SERVER_PORT > PATH/TO/PKG_IDENTIFIERS
      4.2 Activate all listed probe packages
            pdm userpane activate probe_packages -s SERVER_IP -p SERVER_PORT < PATH/TO/PKG_IDENTIFIERS
      5. Delete all the existing mos(optional)
      5.1 List all managed objects' key
            pdm userpane list mos --filter mokey -s SERVER_IP -p SERVER_PORT > PATH/TO/MO_IDENTIFIERS
      5.2 Delete all the mos by the input file
            pdm userpane delete mos -s SERVER_IP -p SERVER_PORT < PATH/TO/MO_IDENTIFIERS
      6. Batch Create Managed Objects
      6.1 Generate file contains a serial of IP addresses
            pdm httperf ip 500 --start 192.168.5.1 > PATH/TO/IPS
      6.2 Generate a pressure data file by the factor(ip addresses) and template file
            pdm httperf template create_mo.json --sessions 10 --bursts 50 < PATH/TO/IPS > PATH/TO/PRESSURE/FILE
      6.3 Executing the pressure test work, using httperf send concurrent requests to the server
            pdm httperf pressure PATH/TO/PRESSURE/FILE -s SERVER_IP -p SERVER_PORT
      7. Analysis the result log
      7.1 Get the log by FTP
            pdm ftp get PATH/TO/LOG/1 PATH/TO/LOG/2 --to LOCAL/DIR -s FTP_IP -p FTP_PORT --user ACCOUNT --passwd PASSWORD
      7.2 Analysis the log, and save the result into database
            pdm database migrate up|down|reset|backup PATH/TO/STEP1 PATH/TO/STEP2
            pdm analysis create_mo PATH/TO/LOG/1 PATH/TO/LOG/2 --timestamp 10:20:30,000 > ANALYSIS/RESULT 2>ANALYSIS/ERROR
            pdm database import ANALYSIS/RESULT
      7.3 Validate the results
            pdm database validate user_tasks -c "count(0) = 500" -c "avg(cost) <= 60" -c "max(cost) < 100" -c "max(concurrent) > 10"
  EOF

  CONFIGURATION = <<-EOF
    Configuration
    Pdm tools support simplify command configurations by those ways:
    1. Multiple level configurations
      You can config a:
      1.1 System wide configuration
        Linux:   /etc/.pdmrc
        Windows: "C:/Documents and Settings/All Users/Application Data/.pdmrc" (for example)
      1.2 User configuration
        Linux:   ~/.pdmrc
        Windows: "C:/Documents and Settings/Administrators/.pdmrc" (for example)
      1.3 Execution configuration
        with --config-file option specified
      and those configurations will be override by user specified options or arguments

    2. Different command configurations or arguments

      backtrace: true|false
      benchmark: true|false
      verbose:   true|false
      pdm:
        --default: default option for all command
      ftp:
        --server: "default ftp server address"
        --port: "default ftp server port"
        get: "default file path"
      database:
        --server: "default database address"
        --port: "default database port"
        --database: "default database name"
        --user: "default database user"
        --passwd: "default database password"
  EOF

  # :startdoc:

  def initialize
    super 'help', "Provide help on the 'pdm' command"
  end

  def arguments # :nodoc:
    args = <<-EOF
      commands      List all 'pdm' commands
      examples      Show examples of 'pdm' usage
      config        Show configuration of 'pdm'
      <command>     Show specific help for <command>
    EOF
    return args.gsub(/^\s+/, '')
  end

  def usage # :nodoc:
    "#{program_name} ARGUMENT"
  end

  def execute
    command_manager = Pdm::CommandManager.instance
    arg = options[:args][0]

    if begins? "commands", arg then
      out = []
      out << "PDM commands are:"
      out << nil

      margin_width = 4

      desc_width = command_manager.command_names.map { |n| n.size }.max + 4

      summary_width = 80 - margin_width - desc_width
      wrap_indent = ' ' * (margin_width + desc_width)
      format = "#{' ' * margin_width}%-#{desc_width}s%s"

      command_manager.command_names.each do |cmd_name|
        summary = command_manager[cmd_name].summary
        summary = wrap(summary, summary_width).split "\n"
        out << sprintf(format, cmd_name, summary.shift)
        until summary.empty? do
          out << "#{wrap_indent}#{summary.shift}"
        end
      end

      out << nil
      out << "For help on a particular command, use 'pdm help COMMAND'."
      out << nil
      out << "Commands may be abbreviated, so long as they are unambiguous."
      out << "e.g. 'pdm f put' is short for 'pdm ftp put'."

      say out.join("\n")

    elsif begins? "options", arg then
      say Pdm::Command::HELP

    elsif begins? "examples", arg then
      say EXAMPLES

    elsif begins? "config", arg then
      say CONFIGURATION

    elsif options[:help] then
      command = command_manager[options[:help]]
      if command
        # help with provided command
        command.invoke("--help")
      else
        alert_error "Unknown command #{options[:help]}.  Try 'pdm help commands'"
      end

    elsif arg then
      possibilities = command_manager.find_command_possibilities(arg.downcase)
      if possibilities.size == 1
        command = command_manager[possibilities.first]
        command.invoke("--help")
      elsif possibilities.size > 1
        alert_warning "Ambiguous command #{arg} (#{possibilities.join(', ')})"
      else
        alert_warning "Unknown command #{arg}. Try pdm help commands"
      end

    else
      say Pdm::Command::HELP
    end
  end

end

