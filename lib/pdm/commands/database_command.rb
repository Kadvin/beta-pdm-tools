require 'pdm/command'
require 'pdm/generic_option'

module Pdm
  module Commands
    class DatabaseCommand < Pdm::Command
      include Pdm::GenericOption

      def initialize
        super 'database', 'Manipulate(migrate, validate, import, backup...) the database',
              :adapter => "mysql", :encoding => "utf8"

        add_db_options
        add_option('-c','--condition COND', String, "Conditions against target tables") do |cond, options|
          options[:conditions] ||= []
          options[:conditions] << cond
        end
        add_option('-t','--tag TAG', String, "Backup tags used in migrate") do |tag, options|
          options[:tag] = tag
        end

      end #end of the initialize

      def usage
        usages = <<-EOF
          #{program_name} migrate up|down|reset|backup PATH/TO/STEPS [options]
          Or:    #{program_name} import PATH/TO/RESULTS [options]
          Or:    #{program_name} validate TABLE
        EOF
        usages.gsub!(/^\s+/, '')
        usages.gsub!(/\n$/, '')
        usages
      end

      def arguments
        args = <<-EOF
          ACTION           the database action
          ARGUMENTS        the action arguments, if the arguments is migration steps, we will use all steps as default
        EOF
        args.gsub(/^\s+/, '')
      end

      def defaults
        "--adapter mysql --encoding utf8"
      end

      def execute
        require "actor/database"
        args = options.delete(:args)
        database = Actor::Database.new options
        sub_cmd = args.shift
        database.send(sub_cmd, *args)
      end # end of execute

    end #end of the DatabaseCommand
  end
end
