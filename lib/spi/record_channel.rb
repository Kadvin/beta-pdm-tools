# @author Kadvin, Date: 12-5-16
require "spi"

module Spi
  #
  # = The threshold event
  #
  class RecordChannel < Channel
    # change the default element name of the RecordChannel
    # this model mapping to /records actually
    set_element_name :record

    def parse(resp)
      super(resp)
      # multiple file contents
      files = resp.body.split("\r\n\r\n")
      # maybe some empty file content
      files.reject!{|content| content.blank?}
      files
    end
  end
end
