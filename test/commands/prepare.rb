# add parent folder into ruby lib path
require File.join(File.dirname(__FILE__), "../env")

require "pdm"
require 'pdm/runner'
require "pdm/exceptions"

# for all specs to use
def run(cmd)
  args = cmd.split
  Pdm::Runner.new.run args
end

