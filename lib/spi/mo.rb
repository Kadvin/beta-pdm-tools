# @author Kadvin, Date: 12-5-14
require "spi"

module Spi
  #
  # = The mo resource
  #
  class Mo < Base

    ################################################################################
    # Business methods
    ################################################################################

    ##
    #  Retrieve the mo
    #
    def retrieve
      put(:retrieve).tap do |resp|
        load(JSON.parse(resp.body))
      end
    end
    # user can call retrieve and retrieve! as same
    alias_method :retrieve!, :retrieve

    ##
    # forbid the mo
    #
    def forbid
      put(:forbid).tap do |resp|
        self.state = "forbid"
      end
    end
    alias_method :forbid!, :forbid

    ##
    # unforbid the mo
    #
    def unforbid
      put(:unforbid).tap do |resp|
        self.state = "unforbid"
      end
    end
    alias_method :unforbid!, :unforbid

    ##
    # Get a indicator value of this mo
    #
    def get_indicator(indicator, options = {}, args = {})
      options.stringify_keys!
      options.assert_valid_keys(*%W[fresh force timeout priority])
      result = nil
      # convert post syntax into get
      post("indicators/#{indicator}", options.merge(:_method => :GET), args.to_json).tap do |resp|
        result = resp.body
      end
      # try to convert response as json, or return it directly
      begin
        Indicator.new JSON.parse!(result)
      rescue JSON::ParserError
        result
      end
    end

    ##
    #  Perform an operation of this mo
    #
    def perform_operation(operation, options = {}, args = {})
      options.stringify_keys!
      options.assert_valid_keys(*%W[fresh force timeout priority])
      result = nil
      put("operations/#{operation}", options, args.to_json).tap do |resp|
        result = resp.body
      end
      # try to convert response as json, or return it directly
      begin
        Indicator.new JSON.parse!(result)
      rescue JSON::ParserError
        result
      end
    end

    ##
    # Get the threshold rules of this mo, can accept filter like
    #  {
    #    :name => "somebody",
    #    :creator => "somebody",
    #    :source => "source pattern"
    #  }
    #
    def threshold_rules(filter = {})
      filter.stringify_keys!
      filter.assert_valid_keys(*%W[name creator source])
      rules = []
      get(:threshold_rules, filter).each do |item|
        rules << ThresholdRule.new(item)
      end
      rules
    end


    ##
    # Get the record rules of this mo, can accept filter like
    #  {
    #    :name => "somebody",
    #    :creator => "somebody",
    #    :source => "source pattern"
    #  }
    #
    def record_rules(filter = {})
      filter.stringify_keys!
      filter.assert_valid_keys(*%W[name creator source])
      rules = []
      get(:record_rules, filter).each do |item|
        rules << RecordRule.new(item)
      end
      rules
    end

    ################################################################################
    # twisted super methods
    ################################################################################
    def encode(options = {})
      # PDM mos only accept endpoint, accesses, properties what ever you create or update a mo
      super(options.merge(:only => %W[endpoint accesses properties]))
    end

    def load(attributes, remove_root = false)
      super
      # think id as mokey, skip old id
      # because PDM use this as resource identifier
      self.id = @attributes["mokey"]
    end

    class << self
      ##
      #  == Create a MO
      #  Accept those arguments:
      #    specified mo type (mandatory)
      #    attributes(json string or map)(mandatory)
      #    retrieve it or not(default false, means not retrieve it's properties after mo created)
      #
      def create(mo_type, attributes, retrieve = false)
        mo = nil
        attributes = attributes.to_json unless attributes.is_a? String
        post(mo_type, {:retrieve => retrieve}, attributes).tap do |resp|
          mo = Mo.new(JSON.parse(resp.body))
          # mark the mo as persisted, instead of n
          mo.instance_variable_set :@persisted, true
        end
        mo
      end

      ##
      # Read the mo indicator directly

      # * mo_type: the mo type
      # * attributes: the mo endpoint, access, properties as input hash
      # * args: the arguments passed to the indicator
      def read_indicator(mo_type, attributes, args = nil)
        attributes.merge(:arguments => args) if args
        result = nil
        post(mo_type + "/read_indicator", attributes.to_json).tap do |resp|
          result = resp.body
        end
        begin
          Indicator.new JSON.parse!(result)
        rescue JSON::ParserError
          result
        end
      end

      ##
      # == Find mo by the endpoint
      # Accept the endpoint value(json or string) as mandatory parameter
      #
      def find_by_endpoint(mo_type, endpoint)
        endpoint = endpoint.to_json unless endpoint.is_a? String
        mo = nil
        get("#{mo_type}/by_endpoint", :value => endpoint).tap do |hash|
          mo = Spi::Mo.new(hash)
          # mark the mo as persisted, instead of n
          mo.instance_variable_set :@persisted, true
          mo
        end
        mo
      end

      ##
      # ==Count the mo with options
      #  * type(optional): the mo type
      #  * keyword(optional): the mo endpoint, accesses, properties keyword
      def count(options = {})
        options.stringify_keys!
        options.assert_valid_keys(*%W[type keyword])
        resp = connection.get(custom_method_collection_url(:count, options), headers)
        resp.body.to_i
      end
    end
  end
end