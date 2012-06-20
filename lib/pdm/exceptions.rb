##
# Base exception class for RubyGems.  All exception raised by RubyGems are a
# subclass of this one.
module Pdm
  class Exception < RuntimeError; end

  class CommandLineError < Exception; end

  ##
  # Signals that a file permission error is preventing the user from
  # installing in the requested directories.
  class FilePermissionError < Exception
    def initialize(path)
      super("You don't have write permissions into the #{path} directory.")
    end
  end

  ##
  # Used to raise parsing and loading errors
  class FormatException < Exception
    attr_accessor :file_path
  end


  class OperationNotSupportedError < Exception; end

  ##
  # Signals that a remote operation cannot be conducted, probably due to not
  # being connected (or just not finding host).
  #--
  # TODO: create a method that tests connection to the preferred gems server.
  # All code dealing with remote operations will want this.  Failure in that
  # method should raise this error.
  class RemoteError < Exception; end


  class VerificationError < Exception; end

  ##
  # Raised to indicate that a system exit should occur with the specified
  # exit_code

  class SystemExitException < SystemExit
    attr_accessor :exit_code

    def initialize(exit_code)
      @exit_code = exit_code

      super "Exiting Pdm Tools with exit_code #{exit_code}"
    end

  end
end
