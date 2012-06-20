# @author Kadvin, Date: 12-5-16
require "spi"

module Spi
  #
  # = The threshold event
  #
  class EventChannel < Channel
    # change the default element name of the EventChannel
    # this model mapping to /events actually
    set_element_name :event

    def parse(resp)
      super(resp)
      JSON.parse(resp.body)
    end
  end
end
