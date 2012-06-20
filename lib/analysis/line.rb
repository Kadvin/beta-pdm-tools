# @author Kadvin, Date: 12-1-5

require "ostruct"
#
# = A processable log line
#

require "active_support/core_ext/regexp"

module Analysis
  class Line < OpenStruct

    def initialize(file, file_no, log, line_no, md)
      super(:file => file, :file_no => file_no, :log => log, :line_no => line_no, :md => md, :appended => false)
    end

    def append(log)
      self.log << log
      self.appended = true
    end

    alias_method :<<, :append

    def appended?
      self.appended
    end

    # when the line content was changed, regenerate the match data
    def rematch_on_change!(log_ptn)
      return if not self.appended?
      return if not log_ptn.multiline?
      self.md = log_ptn.match(log)
    end

    delegate :[], :to => :md

    def to_s
      "%s:%d %s" % [file, line_no, log]
    end
  end
end