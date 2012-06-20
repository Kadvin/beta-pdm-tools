# encoding: utf-8
# @author Kadvin, Date: 11-12-20

require "actor"

module Actor
  #
  # = The HTTPERF related tools
  #
  class Pressure < Base

    # ==Use httperf to perform pressure test against target server
    # pdm pressure httperf PATH/TO/PRESSURE/FILE -s SERVER_IP -p SERVER_PORT
    def httperf(pressure_file)
      data = File.new(pressure_file)
      server = options[:server]
      port = options[:port]
      # data.size is supported > 1.9
      total = File.size(data)  # 根据经验， 5k的文件，实际发出的request的size为9k，系数大致为2
      send_buffer = total * 10 # 一般接收缓存比较小，响应值并不大
      recv_buffer = total
      sessions = data.grep /\# Session\#(\d+)/

      cmd = %Q{httperf --hog --send-buffer=#{send_buffer} --recv-buffer=#{recv_buffer} \
    --max-connections=4 --max-piped-calls=32 --server=#{server} --port=#{port} \
    --add-header="Content-Type: text/json\\n" --wsesslog=#{sessions.size},0.001,#{pressure_file} --period=0.0001}
      puts "Try to executing:"
      puts cmd
      #unless RUBY_PLATFORM =~ /(linux|darwin)/
      #  puts "OOPS, the httperf only runs in *nix,  and can't run in windows or mingw!"
      #  exit
      #else
        puts `#{cmd}`
      #end
    end

    # ==Use ab(ApacheBench) to perform pressure test
    def ab(pressure_file)
      raise "Not supported now"
    end
  end

end
