# @author Kadvin, Date: 11-12-26

require "ostruct"
require "core_ext/ipaddr"
require "actor"

#
# = Create all kinds of template
#
module Actor

  class Factor < Base

    # ==Generate a serial of ip addresses
    # pdm template ip total --start 192.168.0.10
    # pdm template ip 3 --start 192.168.3.2  => ["192.168.3.2","192.168.3.3","192.168.3.4"]
    def ip(total = 254)
      total = total.to_i
      start = options[:start] || "192.168.0.1"
      start_ip = IPAddr.new(start, Socket::AF_INET)
      ips = []
      start_ip.iterate(total) { |ip| ips << ip.to_s}
      info("Generate %s to %s total: %d IP addresses" % [ips.first, ips.last, ips.size ])
      puts ips.to_json
    end

    # ==Generate a serial of repeated values
    # pdm template repeat the-mo-key times
    # pdm template repeat mo-key 3 => ["mo-key", "mo-key", "mo-key"]
    def repeat(value, repeats)
      repeats = repeats.to_i
      values = []
      1.upto(repeats){values << value}
      puts values.to_json
    end

    # ==Generate a serial of value, step by *--step*
    # pdm template increase start, total --step step
    # pdm template increase 100 3, --step 2 => [100, 102, 104]
    def increase(value, increases)
      values = []
      curr = value
      step = options[:step] || 1
      1.upto(increases){values << (curr += step)}
      puts values.to_json
    end


  end

end
