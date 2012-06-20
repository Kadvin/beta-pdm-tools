# @author Kadvin, Date: 11-12-20

require "actor"
require "net/ftp"
#
# = The Ftp server
#
module Actor

  class FtpServer < Base

    # Download target files to local dir
    def get(local_dir, *target_files)
      connect! do |ftp|
        begin
          old = Dir.pwd
          debug "Change dir to: %s" % local_dir
          Dir.chdir local_dir
          target_files.each do |file|
            info "%s: Downloading %s to %s" % [Time.now.strftime("%H:%M:%S"), file, local_dir]
            # TODO 1. support file pattern 2. support make local dir for nested files
            ftp.get(file)
          end
        ensure
          Dir.chdir old
        end
      end
    end

    def put(remote_dir, *local_files)
      connect! do |ftp|
        #ftp.sendcmd("cd #{remote_dir}") # ftp server not implements it now
        local_files.each do |file|
          info "%s: Uploading %s to %s" % [Time.now.strftime("%H:%M:%S"), file, remote_dir]
          ftp.put(file, File.join(remote_dir, File.basename(file)))
        end
      end
    end

    # Accept all other command and send them to ftp server directly
    def method_missing(name, *args)
      ftp = Net::FTP.new
      if ftp.respond_to? name
        connect! do |ftp|
          puts ftp.send(name, *args)
        end
      else
        super
      end
    end

    def to_s
      "%s:%d" % [options[:server], options[:port]]
    end

    private
    def connect!
      begin
        ftp = Net::FTP.new
        debug "Connect to: %s" % to_s
        ftp.connect(options[:server], options[:port])
        user, passwd = options[:user], options[:passwd]
        debug "Login by: %s/%s" % [user, passwd ]
        ftp.login(user, passwd)
        yield(ftp)
      ensure
        ftp.close rescue nil
      end
    end

  end

end
