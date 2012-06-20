# @author Kadvin, Date: 12-6-5

require "spi"
require "ostruct"
module Spi
  #
  # = The indicator value
  # like: {"key"=>"d0d836ae-0081-4405-809b-b2f589d0dcee/uptime/0",
  #        "moKey"=>"d0d836ae-0081-4405-809b-b2f589d0dcee",
  #        "actionName"=>"uptime", "value"=>"", "timestamp"=>1338888642828}
  #
  class Indicator < OpenStruct
    def initialize(hash)
      super(hash)
    end
  end
end