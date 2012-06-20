$: << File.join(File.dirname(__FILE__), "../")
$: <<  File.join(File.dirname(__FILE__), "../lib")
require "rubygems"
require "rspec"
require "spi"


def iterate(limit)
  offset = 0
  begin
    start = Time.now
    mos = Spi::Mo.all(:params=>{:offset => offset, :limit => limit})
    p "Mos[%d - %d](%d) taken: %ds" % [offset, offset + limit, mos.size, Time.now - start]
    offset += limit
    mos.each{|mo| p mo.endpoint.inspect}
    p
  end while(not mos.empty?)
end

Spi::Base.site = "http://20.0.8.128:8020/v1"
Spi::Base.timeout = 60 * 10 # 10 minutes
p "Iterate against: %s" % Spi::Base.site
i = 0
batch_size = ARGV.first.nil? ? 100 : ARGV.first.to_i
while(true)
  i += 1
  p "Iterate mos round %d, batch size = %d" % [i, batch_size]
  iterate(batch_size)
  # sleep 10 seconds
  p "sleep 10 seconds to iterate next time"
  sleep(10)
end