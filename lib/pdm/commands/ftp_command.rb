require 'pdm/command'
require 'pdm/generic_option'

module Pdm
  module Commands
    class FtpCommand < Pdm::Command
      include Pdm::GenericOption

      def initialize
        super 'ftp', 'Use ftp to process files between local and remote ftp server',
              :to => ".", :port => "21"

        add_server_option("FTP_SERVER")
        add_port_option("FTP_PORT")
        add_user_option("FTP_USER")
        add_passwd_option("FTP_PASSWD")

        add_option('--to TARGET_DIR', String,
                   "Target path, remote path for put, local path for get") do |target_dir, options|
          options[:to] = target_dir
        end
      end #end of the initialize

      def arguments
        args = <<-EOF
          CMD           get/put/list... FTP commands
          FILE1 FILE2   File to be processed by FTP
        EOF
        args.gsub(/^\s+/, '')
      end

      def defaults
        "--to ."
      end

      def usage
        "#{program_name} get|put [FILES...]"
      end

      def execute
        require "actor/ftp_server"
        to = options.delete(:to)
        args = options.delete(:args)
        ftp = Actor::FtpServer.new(options)
        sub_cmd = args.shift
        ftp.send(sub_cmd, to, *args)
      end # end of execute

    end #end of the FtpCommand
  end
end
