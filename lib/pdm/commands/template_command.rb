require 'pdm/command'
require 'pdm/generic_option'

module Pdm
  module Commands
    class TemplateCommand < Pdm::Command
      include Pdm::GenericOption

      def initialize
        super 'template', 'Generate template'

        add_option('--sessions SESSION', Integer,
                   "How many sessions should be generated") do |sessions, options|
          options[:sessions] = sessions
        end
        add_option('--bursts BURSTS', Integer, "How many concurrent request in one session") do |bursts, options|
          options[:bursts] = bursts
        end
        add_option('--factor_file FACTOR', String, "Generated factors file") do |factor_file, options|
          options[:factor_file] = factor_file
        end

      end #end of the initialize

      def usage
        usages = <<-EOF
          #{program_name} TEMPLATE_TYPE PATH/TO/TEMPLATE/JSON > OUTPUT/FILE
        EOF
        usages.gsub!(/^\s+/, '')
        usages.gsub!(/\n$/, '')
        usages
      end

      def arguments
        usages = <<-EOF
          TEMPLATE_TYPE        template type, such as create_mo, sample_mo, delete_mo ... etc
          TEMPLATE_PATH        the path to the template file, I'll use the default templates/$TEMPLATE_TYPE.json
        EOF
        usages.gsub(/^\s+/, '')
      end

      def defaults
        ""
      end

      def execute
        require "actor/template"
        args = options.delete(:args)
        sub_cmd = args.shift
        template = Actor::Template.new options
        args.unshift nil if args.empty?
        template.send(sub_cmd, *args)
      end # end of execute

    end #end of the TemplateCommand
  end
end
