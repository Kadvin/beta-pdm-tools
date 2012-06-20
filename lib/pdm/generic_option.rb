require 'rubygems'

##
# Support generic Options
#
module Pdm::GenericOption

  ##
  # Add the --prerelease option to the option parser.

  def add_server_option(server_name = "SERVER", *wrap)
    add_option("-s", "--server #{server_name}",
               "The server ip address", *wrap) do |value, options|
      options[:server] = value
    end
  end

  def add_port_option(port_name = "PORT", *wrap)
    add_option("-p", "--port #{port_name}", Integer,
               "The server port value", *wrap) do |value, options|
      options[:port] = value
    end
  end

  def add_user_option(user_name = "USER", *wrap)
    add_option("-u", "--user #{user_name}",
               "The user name", *wrap) do |value, options|
      options[:user] = value
    end
  end

  def add_passwd_option(pwd_name = "PASSWORD", *wrap)
    add_option("-w", "--passwd #{pwd_name}",
               "The user password", *wrap) do |value, options|
      options[:passwd] = value
    end
  end

  def add_db_options
    add_server_option("DB_SERVER")
    add_port_option("DB_PORT")
    add_user_option("DB_USER")
    add_passwd_option("DB_PASSWD")
    add_option('--adapter ADAPTER', String, "database adapter") do |adapter, options|
      options[:adapter] = adapter
    end
    add_option('--encoding ENCODING', String, "database encoding") do |encoding, options|
      options[:encoding] = encoding
    end
    add_option('--database DB_NAME', String, "database name") do |db, options|
      options[:database] = db
    end
  end
end

