# @author Kadvin, Date: 11-12-26

require "rubygems" # if ruby 1.8
require "json" # json is not in siteruby, but in rubygems
require "active_support/core_ext/hash"
require "actor"

#
# = Create all kinds of template
#
module Actor

  class Template < Base

    # ==Generate a create mo pressure file
    # pdm template create_mo PATH/TO/TEMPLATE --sessions 10 --bursts 5 < PATH/TO/MO.KEYS > PATH/TO/PRESSURE.FILE
    def generate(file )
      # how to break if user doesn't provide any input file
      raw_data = read_file_or_stdin(options[:factor_file])
      factors = JSON.parse!(raw_data)
      template = TemplateFile.new(file)
      sessions, bursts = options[:sessions], options[:bursts]
      raise "You must specify --sessions NUMBER" unless sessions
      raise "You must specify --bursts NUMBER" unless bursts
      1.upto(sessions) do |session_seq|
        puts "# Session#%d " % session_seq
        session_start = (session_seq - 1) * bursts
        puts template.session(session_seq, factors[session_start])
        1.upto(bursts) do |burst_seq|
          index = (session_seq - 1) * bursts + burst_seq - 1
          if index > factors.size - 1
            warn("The factors(%d) you provide is less than the sessions(%d) * bursts(%d) = %d requirements" %
                     [factors.size, sessions , bursts, sessions * bursts])
            break
          end
          factor = factors[index]
          puts template.request(session_seq, burst_seq, factor) rescue break
        end
        puts
      end
    end

    %W{create_mo create_threshold create_record create_threshold_batch
      delete_mo delete_threshold delete_record  delete_file download_file
      batch_retrieve_mo update_record_rule update_threshold_rule}.each do |template|
      define_method template do |file|
        file = File.join(File.dirname(__FILE__), "../../templates/#{template}.json") if file.nil?
        generate(file)
      end
    end

    # ==Generate a sample mo pressure file
    # pdm template sample_mo PATH/TO/TEMPLATE --sessions 10 --bursts 5 < PATH/TO/MO.KEYS > PATH/TO/PRESSURE.FILE
    def sample_mo(file = nil)
      file = File.join(File.dirname(__FILE__), "../../templates/sample_mo.json") if file.nil?
      raw_data = read_file_or_stdin(options[:factor_file])
      factors = JSON.parse!(raw_data)
      template = TemplateFile.new(file)
      sessions, bursts = options[:sessions], options[:bursts]
      raise "You must specify --sessions NUMBER" unless sessions
      raise "You must specify --bursts NUMBER" unless bursts
      1.upto(sessions) do |session_seq|
        puts "# Session#%d " % session_seq
        factor = factors[session_seq - 1]
        puts template.session(session_seq, factor)
        1.upto(bursts) do |burst_seq|
          puts template.request(session_seq, burst_seq, factor) rescue break
        end
        puts
      end
    end
  end

  class TemplateFile
    attr_accessor :session_template, :request_template

    def initialize(path)
      super()
      @json = JSON.parse!(IO.read(path))
      self.session_template = @json['session']
      self.request_template = @json['request']
    end

    def session(session, factor = nil) #sequence is used by eval as context binding
      template = self.session_template.dup
      process(template) do |item|
        exp = expression(item)
        eval(exp, binding)
      end
      url(template.delete('url'), template)
    end

    def request(session, burst, factor) #sequence,factor is used by eval as context binding
      template = if self.request_template.nil?
                   rq = @json["request[#{burst}]"]
                   raise "Can't find request template for burst = %d" % burst if rq.nil?
                   rq.dup
                 else
                   self.request_template.dup
                 end
      process(template) do |item|
        str = eval(expression(item), binding)
        if item.is_a? Hash
          str.gsub! /"/, "\\\""
          "'#{str}'"
        else
          str
        end
      end
      url("  " + template.delete('url'), template)
    end

    private
    def process(template)
      template.each { |key, item| template[key] = yield(item) }
    end

    def url (url, options)
      format("%s %s", url, options.map { |k, v| "%s=%s" % [k, v] }.join(" "))
    end

    def expression(origin) # convert origin string into ruby expression
      if origin.is_a? Hash # json hash as a string
        exp = origin.to_json
      else
        exp = origin
      end
      exp.gsub!(/\\\#\{/, "\#{") # replace \#{xxx} as #{xxx} to be evaluable
      "%Q{#{exp}}" # exp is treat as a ruby string evaluation by: %Q{xxx yyy zzz}
    end
  end
end
