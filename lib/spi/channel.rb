# @author Kadvin, Date: 12-5-16

require "spi"

module Spi
  #
  # = The rule base class
  #
  class Channel < Base
    attr_accessor :anchor, :limit

    include Enumerable

    def each
      until((items = list(:anchor => anchor, :limit => limit)).empty?)
        items.each do |item|
          yield(item)
        end
      end
    end

    ##
    #  ==  List events or lines in this channel
    # return the got data, and the anchor will be set as current channel's attribute
    #
    def list(options = {})
      options.symbolize_keys
      options.assert_valid_keys(:anchor, :limit)
      options.reverse_merge!(:anchor => nil, :limit => 10)
      items = []
      connection.get(self.class.custom_method_collection_url(name, options), self.class.headers).tap do |resp|
        got = parse(resp)
        raise "Can't parse items from response" if not got.is_a? Array
        items.concat(got)
      end
      items
    end

    def parse(resp)
      self.anchor = resp.header["anchor"]
      []#return empty array when no children implement this method to avoid class cast or nil exception
    end

    class << self

      def all
        events = []
        connection.get(custom_method_collection_url(:channels), self.headers).tap do |resp|
          hash = JSON.parse(resp.body)
          hash.each_pair do |name, count|
            events << new(:name => name, :count=>count)
          end
        end
        events
      end
    end
  end
end