# @author Kadvin, Date: 12-5-16
require "spi"

module Spi
  #
  # = The rule base class
  #
  class Rule < Base
    # extra rules after new rule created, respond by the server
    attr_reader :extra_rules

    ################################################################################
    # twisted super methods
    ################################################################################

    def encode(options = {})
      # exclude key and managedObject when update
      options.merge(:except=>%W[key managedObject]) if not new?
      super(options)
    end

    # the response is an array after creation
    def load(attributes, remove_root = false)
      if(attributes.is_a?(Array))
        super(attributes.shift, remove_root)
        unless( attributes.empty? )
          @extra_rules = []
          attributes.each{|attrs| @extra_rules << self.class.new(attrs)}
        end
      else
        super
      end
      self.id = @attributes["key"]
    end

    class << self
      ##
      # == Create threshold rules by the attributes
      # we will return one or more attributes according to your attributes["managedObject"] description
      # if server can map a lot of mos, then it will create several rule for each mo and return them
      # else it will create only one rule
      # if can't mapping any one mo, then server will raise error
      def create(attributes)
        attributes = JSON.parse(attributes) if attributes.is_a? String
        rule = new(attributes)
        rule.save
        result = [rule]
        result.concat rule.extra_rules unless rule.extra_rules.blank?
        result
      end

      ##
      # ==Count the rules with options
      #  * moType(optional): the mo type
      #  * keyword(optional): the rule name, source, creator liked
      def count(options = {})
        options.stringify_keys!
        options.assert_valid_keys(*%W[moType keyword])
        resp = connection.get(custom_method_collection_url(:count, options), headers)
        resp.body.to_i
      end
    end
  end
end
