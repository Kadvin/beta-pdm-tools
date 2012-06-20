# add parent folder into ruby lib path
$stderr.puts "Load test env now..."

$: << File.join(File.dirname(__FILE__), "../")
$: << File.join(File.dirname(__FILE__), "../lib")

require "rubygems"
require "rspec"

def establish!()
  require "active_record"
  require "yaml"
  options = YAML.load_file(File.join(File.dirname(__FILE__), "db.yml"))
  ::ActiveRecord::Base.establish_connection(options)
  yield if block_given?
end
