# @author yuan, Date: 2012-03-23

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

  class Adminpane < Base

    def initialize(*args)
      super
      @client = Net::HTTP.new(server, port)
      @header = {}
      @username = 'admin'
      @password = 'admin'
    end

    #
    # adminpane new_session
    #
    def new_session
      info "New Session..."
      get '/login'
    end

    #
    # adminpane create_session
    #
    def create_session
      info "Create Session..."
      response = post '/login', "loginid=#{@username}&password=#{@password}"
      @header = {'Cookie' => response['set-cookie']}
    end

    #
    # adminpane destroy_session
    #
    def destroy_session
      info "Destroy session"
      create_session
      get '/exit'
    end

    def list_engines
      info "List Engines"
      create_session
      get '/engines'
    end

    def get_engine(id)
      info "List Engines"
      create_session
      get "/engines/#{id}"
    end

    def list_mos
      info "List mos"
      create_session
      get "/mos"
    end

    def paginate_mos(page, per_page)
      info "Paginate Engines"
      create_session
      get "/mos?pageIndex=#{page}&pageSize=#{per_page}"
    end

    def show_mos_type(type)
      info "Listing mos with type: #{type}"
      create_session
      get "/mos/list/#{type}"
    end

    def show_mo(id)
      info "Show mo with id: #{id}"
      create_session
      get "/mos/#{id}"
    end

    def paginate_probes(page, per_page)
      info "Paginate probe packages"
      create_session
      get "/probe_packages?pageIndex=#{page}&pageSize=#{per_page}"
    end

    def show_probe(id)
      info "Show probe packages"
      create_session
      get "/probe_packages/#{id}/show.html"
    end

    def list_assign_rules
      info "List assign rules"
      create_session
      get "/assign_rules"
    end

    def show_assign_rule(id)
      info "List assign rules"
      create_session
      get "/assign_rules/#{id}"
    end

    def list_subscribe_rules
      info "List subscribe rules"
      create_session
      get "/subscribe_rules"
    end

    def paginate_subscribe_rules(page, per_page)
      info "Paginate subscribe rules"
      create_session
      get "/subscribe_rules?pageIndex=#{page}&pageSize=#{per_page}"
    end

    def show_subscribe_rule(id)
      info "Paginate subscribe rules"
      create_session
      get "/subscribe_rules/#{id}"
    end

    def list_subscribe_rules_by_type(type)
      info "List subscribe rules by type: #{type}"
      create_session
      get "/subscribe_rules?rule_type=#{type}"
    end

    def list_meta_models(type)
      info "List meta models by type: #{type}"
      create_session
      get "/managed_classes/#{type}"
    end

    def query_operation_logs(params)
      info "Querying operation logs"
      create_session
      get "/operation_logs/inquire?#{params}"
    end

    def add_assign_rule(name, engine_id)
      info 'Adding assign rule'
      create_session
      form_data="AssignRule/priority=DefaultRule&AssignRule/name=#{name}&AssignRule/engine/key=#{engine_id}"
      post "/assign_rules", form_data
    end

    def update_assign_rule(rule_name, engine_id)
      info 'Updating assign rule'
      create_session
      form_data="AssignRule/priority=DefaultRule&AssignRule/name=#{rule_name}&ruleKey=#{rule_name}&AssignRule/engine/key=#{engine_id}"
      post "/assign_rules?_method=PUT", form_data
    end

    def delete_assign_rule(rule_name)
      info 'Updating assign rule'
      create_session
      post "/assign_rules/delete/#{rule_name}?_method=DELETE", nil
    end

    def cancel_assign_rule(rule_name)
      info 'Cancel assign rule'
      create_session
      post "/assign_rules/cancel/#{rule_name}", '_method=GET&seq=1'
    end

    def disable_engine(id)
      info 'Disable engine'
      create_session
      post "/engines/#{id}/disable", '_method=POST&seq=1'
    end

    def enable_engine(id)
      info 'Enable engine'
      create_session
      post "/engines/#{id}/enable", '_method=POST&seq=1'
    end

    def uninstall_probe(id)
      info 'Uninstall probe'
      create_session
      post "/probe_packages/#{id}/unInstall", nil
    end

    def add_ibm_aix_server(domain, ip)
      info 'Adding IBMAixServer'
      create_session
      form_data='_method=POST&retrieve=true&moType=IBMAixServer&' +
        'PSManagedObject_Accesses/SSHParameter/Port=22&' + 
        'PSManagedObject_Accesses/SSHParameter/User=ssh_user_name&' +
        'PSManagedObject_Accesses/SSHParameter/Timeout=5000&' +
        'PSManagedObject_Accesses/SSHParameter/Retries=3&' +
        'PSManagedObject_Accesses/AgentParameter/Port=9001&' +
        'PSManagedObject_Accesses/AgentParameter/Timeout=5000&' +
        'PSManagedObject_Accesses/AgentParameter/Retries=3&' +
        "EndPoint/Domain=#{domain}&EndPoint/IP=#{ip}&EndPoint/Name=EndPointByIP&" +
        'SSHParameter=OSEcho&AgentParameter=OSEcho'
      post "/mos", form_data
    end

    def update_ibm_aix_server(id, domain, ip)
      info 'Update IBMAixServer'
      create_session
      form_data="_method=PUT&retrieve=false&moType=IBMAixServer&id=#{id}&" +
        'PSManagedObject_Accesses/SSHParameter/Port=22&' + 
        'PSManagedObject_Accesses/SSHParameter/User=ssh_user_name&' +
        'PSManagedObject_Accesses/SSHParameter/Timeout=5000&' +
        'PSManagedObject_Accesses/SSHParameter/Retries=3&' +
        'PSManagedObject_Accesses/AgentParameter/Port=9001&' +
        'PSManagedObject_Accesses/AgentParameter/Timeout=5000&' +
        'PSManagedObject_Accesses/AgentParameter/Retries=3&' +
        "EndPoint/Domain=#{domain}&EndPoint/IP=#{ip}&EndPoint/Name=EndPointByIP&" +
        'SSHParameter=OSEcho&AgentParameter=OSEcho'
      post "/mos/#{id}", form_data
    end

    def delete_mo(id)
      info "Delete MO: #{id}"
      create_session
      post "/mos/#{id}", '_method=DELETE&seq=1'
    end

    def query_mo(key_word)
      info "Query MO with key word: #{key_word}"
      create_session
      get "/mos/search/index?q=#{key_word}"
    end

    def to_s
      "%s:%d" % [server, port]
    end

    private
      
      def post(url, data)
        request{ @client.request_post url, data, @header}
      end

      def get(url)
        request{ @client.request_get url, @header}
      end
      
      def request
        $stdout.puts "Request at: #{DateTime.now.strftime('%H:%M:%S.%N')}"
        response = yield
        $stdout.puts "Respond at: #{DateTime.now.strftime('%H:%M:%S.%N')}"
        case response
        when Net::HTTPSuccess, Net::HTTPRedirection
          info "Origin response body: " + response.body
        else
          error_response(response)
        end
        response
      end

      def error_response(response)
        error "Error %s response: \n%s " % [response.code, response.body]
        $stderr.puts "ERROR Code: %s, Message: %s." % [response.code, response.msg]
      end

      def server
        options[:server] 
      end

      def port
        options[:port]
      end

  end
end
