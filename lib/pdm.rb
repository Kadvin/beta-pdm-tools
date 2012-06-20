require "rubygems"
#
# The core module of pdm tool
#
module Pdm
  VERSION = "1.0.0"
  @configuration = nil
  ##
  # The standard configuration object for gems.

  def self.configuration
    @configuration ||= Pdm::ConfigFile.new []
  end

  ##
  # Use the given configuration object (which implements the ConfigFile
  # protocol) as the standard configuration object.

  def self.configuration=(config)
    @configuration = config
  end

  def self.config_file
    File.join Pdm.user_home, '.pdmrc'
  end

  def self.user_home
    @user_home ||= find_home
  end

  private
  def self.find_home
    File.expand_path "~"
  rescue
    if File::ALT_SEPARATOR then
      "C:/"
    else
      "/"
    end
  end
end

