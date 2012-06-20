# encoding: utf-8
# @author Kadvin, Date: 12-6-4

require "accept"
require "active_support/ordered_hash"
#
# = API Delay
#
module Accept
  class ApiDelay < Worker

    def initialize(seq, delay)
      super
      domain = self.name
      ip =  "104.104.104.#{self.seq + 1}"
      new_mo_str = <<-MO_STR
      {
        "endpoint" : {
              "Domain" : "#{domain}",
              "IP" : "#{ip}"
        },
        "accesses" : {
              "SnmpParameter" :
                 {
                    "Timeout" : 2000,
                    "Port" : 65533,
                    "Retries" : 3,
                    "Version_Set" : "SNMPV1",
                    "Community_Get" : "public",
                    "Community_Set" : "private",
                    "Version_Get" : "SNMPV1"
                 }
           }
      }
      MO_STR
      @operations = ActiveSupport::OrderedHash.new
      @operations[:create_mo] = proc do
        begin
          @mo = Spi::Mo.create(:NetworkDevice, new_mo_str, true)
        rescue
          $stderr.puts "Failed create mo, try to find it and destroy it now"
          report_error $!
          @mo = Spi::Mo.find_by_endpoint(:NetworkDevice, :Domain => domain, :IP => ip)
          @mo.destroy
          @mo = Spi::Mo.create(:NetworkDevice, new_mo_str, true)
        end
      end
      @operations[:update_mo] = proc do
        raise "Can't update mo because of it creation failed" unless @mo
        @mo.accesses.SNMPPARAMETER.Timeout = 3000
        @mo.save
      end
      @operations[:retrieve_mo] = proc do
        raise "Can't retrieve mo because of it creation failed" unless @mo
        @mo.retrieve
      end
      @operations[:delete_mo] = proc do
        raise "Can't delete mo because of it creation failed" unless @mo
        @mo.destroy
      end
    end
  end
end
