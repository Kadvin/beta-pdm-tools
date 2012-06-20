# @author Kadvin, Date: 11-12-20

#
# = The PDM Server
#

require "rubygems" # if ruby 1.8
require "json"     # json is not in siteruby, but in rubygems
require "active_support/core_ext/hash"
require "actor"
require "net/http"
require "uri"
require "ostruct"

module Actor

  class Userpane < Base

    #
    # userpane list mos --filter mokey,state
    # userpane index threshold_rules -f managedObject
    #
    def list(models)
      uri = "/%s" % models
      info "Querying %s... " % [to_s, uri]
      begin
        response = Net::HTTP.start(server, port) do |http|
          http.get uri
        end
      rescue Exception
        raise "Can't send list request to %s:%d" % [server, port]
      end
      case response
        when Net::HTTPSuccess
          debug "Origin response body: " + response.body
          origin = JSON.parse!(response.body)
          info "Got %d %s" % [origin.size, models]
          filter = options[:filter]
          if (filter)
            keys = filter.split(",")
            keys.each { |key| key.strip! }
            if (keys.size > 1)
              origin.map! { |hash| hash.slice!(*keys); hash }
            else
              origin.map! { |hash| hash[filter] }
            end
          end
          $stdout.puts origin.to_json
        else
          error_response(response)
      end
    end
    alias_method :index, :list

    def delete(url)
      resp = Net::HTTP.start(server, port) do |http|
        info "Deleting %s " % url
        http.delete url
      end
      case resp
        when Net::HTTPSuccess
          debug "Origin response body: " + resp.body
          puts resp.body
        else
          error_response(resp)
      end
    end

    # userpane delete_file file_name
    def delete_file(file_path)
      delete ("/%s" % file_path)
    end

    # userpane clear mos < INPUT/FILE
    def clear(models)
      info "Clearing %s" % models
      Net::HTTP.start(server, port) do |http|
        raw_keys = $stdin.read
        keys = JSON.parse!(raw_keys)
        keys.each do |key|
          uri = "/%s/%s" % [models, key]
          debug "Deleting %s" % uri
          resp = http.delete uri
          case resp
            when Net::HTTPSuccess
              debug "Origin response body: " + resp.body
              #origin = JSON.parse!(resp.body)
              puts resp.body
            else
              error_response(resp)
          end
        end
      end
    end

    # 
    # pdm userpane get_indicator $mo_key $indicator_name *@
    #
    def get_indicator(mo_key, indicator_names)
      indicator_names.split(/\s*,\s*/).each do |indicator_name|
        Thread.new do
          info "Getting indicator MO:%s, Indicator:%s..." % [mo_key, indicator_name]
          uri = "/mos/%s/indicators/%s" % [mo_key, indicator_name]
          Net::HTTP.start(server,port) do |http|
            response = http.put uri, nil
            case response
            when Net::HTTPSuccess
              debug "Origin response body: " + response.body
              origin = JSON.parse!(response.body)
              puts origin
            else
              error_response(response)
            end
          end
        end.join
      end
    end

    # pdm userpane update_mo $mo_key $params_json_string
    def update_mo(mo_key, *params)
      info "Updating MO:%s" % mo_key
      uri = "/mos/%s" % mo_key
      Net::HTTP.start(server, port) do |http|
        response = http.put uri, params.join
        case response
        when Net::HTTPSuccess
          debug "Origin response body: " + response.body
          origin = JSON.parse!(response.body)
          puts origin
        else
          error_response(response)
        end
      end
    end

    # pdm userpane retrieve_mo $mo_key
    def retrieve_mo(mo_key)
      info "Retrieve MO:%s" % mo_key
      uri = "/mos/%s?retrieve=true" % mo_key
      Net::HTTP.start(server, port) do |http|
        response = http.put uri, nil
        case response
        when Net::HTTPSuccess
          debug "Origin response body: " + response.body
          origin = JSON.parse!(response.body)
          puts origin
        else
          error_response(response)
        end
      end
    end

    # pdm userpane general_query $uri
    def general_query(uri, request_count=1)
      uri = "/%s" % uri
      info "Querying URI:%s" % uri
      request_count.to_i.times do |i|
        Thread.new do
          Net::HTTP.start(server, port) do |http|
            response = http.get uri
            case response
            when Net::HTTPSuccess
              debug "Origin response body: " + response.body
            else
              error_response(response)
            end
          end
        end.join
      end
    end

    # pdm userpane update_record_rule $rule_key $params_json_string
    def update_record_rule(rule_key, params)
      info "Updating record rule: %s" % rule_key
      uri = "/record_rules/%s" % rule_key
      Net::HTTP.start(server, port) do |http|
        response = http.put uri, params
        case response
        when Net::HTTPSuccess
          debug "Origin response body: " + response.body
        else
          error_response(response)
        end
      end
    end

    def to_s
      "%s:%d" % [server, port]
    end

    private
      def error_response(response)
        error "Error %s response: \n%s " % [response.code, response.body]
        $stderr.puts "ERROR Code: %s, Message: %s." % [response.code, response.msg]
      end
      def server; options[:server] end
      def port; options[:port] end

  end
end
