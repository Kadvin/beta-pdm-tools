
require "active_resource"
require "spi/active_resource_hack"

module Spi
  autoload :Base, "spi/base"
  autoload :Mo, "spi/mo"
  autoload :Indicator, "spi/indicator"

  autoload :Rule, "spi/rule"
  autoload :ThresholdRule, "spi/threshold_rule"
  autoload :RecordRule, "spi/record_rule"

  autoload :Channel, "spi/channel"
  autoload :EventChannel, "spi/event_channel"
  autoload :RecordChannel, "spi/record_channel"
end