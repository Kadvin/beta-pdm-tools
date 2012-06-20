# @author Kadvin, Date: 11-12-22

require "actor"
require "analysis/engine"
require "analysis/initializer"

module Actor
  #
  # = The pressure test analyst which can analysis the logs
  #
  class Analyst < Base
    # ==Analysis target files with configured engine
    def analysis(*files)
      start_at = Time.now
      info "Start processing at: %s" % (start_at.strftime("%H:%M:%S"))
      establish! do
        # convert any folder expression into sub array
        files.map! { |file| Dir[file] } # convert the file into array to be compatible to any element contains match data: */?

        # flatten two dimension array int a flattened one
        files.flatten!
        info "Processing files:\n %s" % files.map { |f| "\t" + f }.join("\n")
        ::Analysis::Engine.analysis(files, options) do |user_task|
          user_task.output_as_csv($stdout)
        end
      end
      info "End process at: %s, took: %d seconds" % [Time.now.strftime("%H:%M:%S"), Time.now - start_at]
    end

    # ==Load the case related rule only to accelerate the parsing
    %W[ap_add_assign_rule ap_query_operation_logs ap_list_meta_models 
      ap_show_subscribe_rule ap_list_subscribe_rules 
      ap_show_assign_rule ap_list_assign_rules 
      ap_show_probe ap_paginate_probes ap_show_mo 
      ap_list_mos ap_get_engine ap_list_engines 
      ap_destroy_session ap_create_session 
      create_mo update_mo delete_mo sample_mo
      create_threshold delete_threshold create_record 
      delete_record execute_subscribe get_mo_indicator
      general_query retrieve_mo update_record_rule update_threshold_rule
      get_rule get_event download_file delete_file].each do |pt_case|
      define_method pt_case do |*files|
        require "analysis/rules/#{pt_case}"
        analysis(*files)
      end
    end

    # ==Analysis all cases(load all rules)
    def all(*files)
      Dir[File.join(File.dirname(__FILE__), "../analysis/rules/", "*.rb")].each{|rules| require rules}
      analysis(*files)
    end

  end


end
