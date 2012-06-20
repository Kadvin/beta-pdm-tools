require "ipaddr"
#
# Extends the IPAddr, and make this class comparable, support sequence each others
#
IPAddr.class_eval do
  #
  # == Get a new ip address which is greater than current ip: number
  #
  def +(number)
    raise "Don't support plus two ip!" if number.is_a?(IPAddr)
    IPAddr.new(to_i + number, Socket::AF_INET)
  end

  #
  # ==Judge the real value differ between two ip addr
  #
  def -(another)
    raise "I can differ two IPAddr only!" if not another.is_a?(IPAddr)
    @addr - another.to_i
  end

  # Step between two ip address, skip mask or net be you choice
  def upto(another, skip_mask = true, skip_net = true)
    raise "I can step between two IPAddr only!" if not another.is_a?(IPAddr)
    @addr.upto(another.to_i).each do |value|
      # skip the mask ip such as: 192.168.1.255
      next if skip_mask && is_mask?(value)
      # skip the network address such as: 192.168.1.0
      next if skip_net && is_net?(value)
      yield IPAddr.new(value, Socket::AF_INET)
    end
  end

  # Iterate from the ip address with max steps
  def iterate(max_steps, skip_mask = true, skip_net = true)
    real_step, step = 0, 0
    while (true)
      break if real_step >= max_steps
      ip = IPAddr.new(to_i + step, Socket::AF_INET)
      step += 1
      next if skip_mask && ip.mask?
      next if skip_net && ip.net?
      real_step += 1
      yield(ip)
    end
    ip
  end

  def mask?
    is_mask?(to_i)
  end

  def net?
    is_net?(to_i)
  end

  private
  def is_mask?(value)
    (value & 0b11111111) == 0b11111111
  end

  def is_net?(value)
    (value & 0b11111111) == 0
  end
end
