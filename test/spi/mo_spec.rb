# @author Kadvin, Date: 12-5-14
require File.join(File.dirname(__FILE__), "../env")
require File.join(File.dirname(__FILE__), "../../lib/spi")
#require File.join(File.dirname(__FILE__), "http_mock_ext")

describe "Mo SPI" do

  it "can find all mos" do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/mos.json?type=NetworkDevice", {}, "[%s,%s]" % [@mo_str_1, @mo_str_2], 200, @apache_headers
    end
    mos = Spi::Mo.all(:params => {:type => :NetworkDevice})
    mos.should have(2).items
  end

  it "can find mo by key" do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/mos/9b3f87e4-e983-4683-b295-91ea6dc33e5b.json", {}, @mo_str_1, 200, @apache_headers
    end
    Spi::Mo.find("9b3f87e4-e983-4683-b295-91ea6dc33e5b")
  end

  it "can find mo by endpoint" do
    endpoint = {"Domain" => "a","IP" => "104.104.104.20"}
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/mos/NetworkDevice/by_endpoint.json?value=%7B%22Domain%22%3A%22a%22%2C%22IP%22%3A%22104.104.104.20%22%7D", {}, @mo_str_1, 200, @apache_headers
    end
    mo = Spi::Mo.find_by_endpoint("NetworkDevice", endpoint)
    mo.should_not be_nil
  end

  it "can create the mo" do
    #ActiveResource::HttpMock.respond_to do |mock|
    #  mock.post "/v1/mos/NetworkDevice.json?retrieve=false", {}, @mo_str_1, 200, @apache_headers
    #end
    Spi::Mo.site = "http://localhost:8020/v1"
    mo = Spi::Mo.create(:NetworkDevice, @new_mo_str)
    mo.should_not be_nil
  end

  it "can update mo" do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289.json", {}, @mo_str_1, 200, @apache_headers
      mock.put "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289.json", {}, @mo_str_2, 200, @apache_headers
    end
    mo = Spi::Mo.find("094ea0ef-bfd5-47f4-ac05-070a2bd97289")
    mo.accesses.SNMPPARAMETER.Timeout = 3000
    mo.save
    mo.accesses.SNMPPARAMETER.Timeout.should == 3000
  end

  it "can retrieve mo" do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289.json", {}, @mo_str_1, 200, @apache_headers
      mock.put "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289/retrieve.json", {}, @mo_str_1, 200, @apache_headers
    end
    mo = Spi::Mo.find("094ea0ef-bfd5-47f4-ac05-070a2bd97289")
    mo.retrieve!
  end

  it "can delete mo" do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289.json", {}, @mo_str_1, 200, @apache_headers
      mock.delete "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289.json", {}, "", 200, @apache_headers
    end
    mo = Spi::Mo.find("094ea0ef-bfd5-47f4-ac05-070a2bd97289")
    mo.destroy
  end

  it "can forbid mo" do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289.json", {}, @mo_str_1, 200, @apache_headers
      mock.put "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289/forbid.json", {}, "", 200, @apache_headers
    end
    mo = Spi::Mo.find("094ea0ef-bfd5-47f4-ac05-070a2bd97289")
    mo.forbid!
  end

  it "can unforbid mo" do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289.json", {}, @mo_str_1, 200, @apache_headers
      mock.put "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289/unforbid.json", {}, "", 200, @apache_headers
    end
    mo = Spi::Mo.find("094ea0ef-bfd5-47f4-ac05-070a2bd97289")
    #mo = Spi::Mo.find("efd92eb5-32a3-4400-9a69-12ac61f53b60")
    mo.unforbid!
  end

  it "can get indicator value of the mo" do
    mem = {"peak"=>"20m","low"=>"10m"}
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289.json", {}, @mo_str_1 , 200, @apache_headers
      mock.post "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289/indicators/CPU.json?_method=GET", {}, "90" , 200, @apache_headers
      mock.post "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289/indicators/MEM.json?_method=GET", {}, mem.to_json , 200, @apache_headers
    end
    mo = Spi::Mo.find("094ea0ef-bfd5-47f4-ac05-070a2bd97289")
    mo.get_indicator("CPU").should == "90"
    mo.get_indicator("MEM").should == mem
  end

  it "can perform operation of the mo" do
    itf = [{"idx" => 1, "value" => "123k"}, {"idx" => 2, "value" => "3m"}]
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289.json", {}, @mo_str_1 , 200, @apache_headers
      mock.put "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289/operations/CHANGEIFVLAN.json", {}, "100" , 200, @apache_headers
      mock.put "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289/operations/CHANGEIFSTATUS.json", {}, itf.to_json , 200, @apache_headers
    end
    mo = Spi::Mo.find("094ea0ef-bfd5-47f4-ac05-070a2bd97289")
    v = mo.perform_operation("CHANGEIFVLAN")
    v.should == "100"
    v = mo.perform_operation("CHANGEIFSTATUS")
    v.should == itf
  end

  it "can list threshold rules of the mo" do
    rules = [{"key"=>"key1"},{"key"=>"key2"},{"key"=>"key3"},{"key"=>"key4"},{"key"=>"key5"}]
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289.json", {}, @mo_str_1 , 200, @apache_headers
      mock.get "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289/threshold_rules.json", {}, rules.to_json , 200, @apache_headers
    end
    mo = Spi::Mo.find("094ea0ef-bfd5-47f4-ac05-070a2bd97289")
    rules = mo.threshold_rules
    rules.should have_at_least(5).items
  end

  it "can list record rules of the mo" do
    rules = [{"key"=>"key1"},{"key"=>"key2"},{"key"=>"key3"},{"key"=>"key4"},{"key"=>"key5"}]
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289.json", {}, @mo_str_1 , 200, @apache_headers
      mock.get "/v1/mos/094ea0ef-bfd5-47f4-ac05-070a2bd97289/record_rules.json", {}, rules.to_json , 200, @apache_headers
    end
    mo = Spi::Mo.find("094ea0ef-bfd5-47f4-ac05-070a2bd97289")
    rules = mo.record_rules
    rules.should have_at_least(5).items
  end

  it "can count the mos size" do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/mos/count.json?type=NetworkDevice", {}, "50" , 200, @apache_headers
    end
    total = Spi::Mo.count(:type => :NetworkDevice)
    total.should == 50
  end

  # TODO move them into factory_girl
  before(:all) do
    Spi::Base.site = "http://localhost:8020/v1/"
    @apache_headers = {}
    @mo_str_1 = <<-MO_STR
    {
      "id" : 7,
      "updated_at" : "2012-05-14 15:58:03.718",
      "mokey" : "094ea0ef-bfd5-47f4-ac05-070a2bd97289",
      "state" : "none",
      "created_at" : "2012-05-14 15:58:03.718",
      "motype" : "networkDevice",
      "endpoint" : {
            "Domain" : "a",
            "IP" : "104.104.104.1"
      },
      "accesses" : {
            "SNMPPARAMETER" :
               {
                  "Timeout" : 2000,
                  "Port" : 65533,
                  "Retries" : 3,
                  "Version_Set" : "SNMPV1",
                  "Community_Get" : "public",
                  "Community_Set" : "private",
                  "Version_Get" : "SNMPV1"
               }
         },
      "properties" :
         {
            "VLANS" : null,
            "DEVICETYPE" : "rt",
            "LOCATION" : null,
            "DEVICENAME" : null,
            "SYSTEMOID" : "1.3.6.1.4.1.9",
            "INTERFACES" : null,
            "USERNAME" : null,
            "MANUFACTURER" : null,
            "IPADDRESS" : null,
            "SYSTEMDESCRIPTION" : null
         },
      "indicators" :
         {
            "MACADDRESS" : null,
            "MODULEINFO" : null,
            "TESTCPU" : null,
            "PERFORMANCETESTING" : null,
            "ROUTE" : null,
            "PINGSTATISTIC" : null,
            "MODULE_STATUS" : null,
            "CPU" : null,
            "REMOTEPING" : null,
            "SYSTEMINFO" : null,
            "PKG" : null,
            "TCPCONNECTIONTEST" : null,
            "SNMPRWTEST" : null,
            "PASSIVEPROBETESTING" : null,
            "IPTABLE" : null,
            "MIBNEXTVALUE" : null,
            "SPANNINGTREEPROTOCOL" : null,
            "SYSTEMUPTIME" : null,
            "VLAN" : null,
            "MIBTABLE" : null,
            "MIBGETVALUE" : null,
            "MEM" : null,
            "ARP" : null,
            "INTERFACESCALAR" : null,
            "INTERFACE" : null,
            "TCP_CONNECTION" : null
         },
      "operations" :
         {
            "CHANGEIFVLAN" : null,
            "CHANGEIFSTATUS" : null,
            "MIBSET" : null
         }
    }
    MO_STR

    @mo_str_2 = <<-MO_STR
    {
      "id" : 5,
      "updated_at" : "2012-05-14 15:50:21.531",
      "mokey" : "9b3f87e4-e983-4683-b295-91ea6dc33e5b",
      "state" : "none",
      "created_at" : "2012-05-14 15:50:21.531",
      "motype" : "Networkdevice",
      "endpoint" :
         {
            "Domain" : "a",
            "IP" : "104.104.104.1"
         },
      "accesses" :
         {
            "TELNETPARAMETER" : null,
            "ICMPPARAMETER" : null,
            "SNMPPARAMETER" :
               {
                  "Timeout" : 3000,
                  "Port" : 65533,
                  "Retries" : 3,
                  "Version_Set" : "SNMPV1",
                  "Community_Get" : "public",
                  "Community_Set" : "private",
                  "Version_Get" : "SNMPV1"
               }
         },
      "properties" :
         {
            "VLANS" : null,
            "DEVICETYPE" : "rt",
            "LOCATION" : null,
            "DEVICENAME" : null,
            "SYSTEMOID" : "1.3.6.1.4.1.9",
            "INTERFACES" : null,
            "USERNAME" : null,
            "MANUFACTURER" : null,
            "IPADDRESS" : null,
            "SYSTEMDESCRIPTION" : null
         },
      "indicators" :
         {
            "MACADDRESS" : null,
            "MODULEINFO" : null,
            "TESTCPU" : null,
            "PERFORMANCETESTING" : null,
            "ROUTE" : null,
            "PINGSTATISTIC" : null,
            "MODULE_STATUS" : null,
            "CPU" : null,
            "REMOTEPING" : null,
            "SYSTEMINFO" : null,
            "PKG" : null,
            "TCPCONNECTIONTEST" : null,
            "SNMPRWTEST" : null,
            "PASSIVEPROBETESTING" : null,
            "IPTABLE" : null,
            "MIBNEXTVALUE" : null,
            "SPANNINGTREEPROTOCOL" : null,
            "SYSTEMUPTIME" : null,
            "VLAN" : null,
            "MIBTABLE" : null,
            "MIBGETVALUE" : null,
            "MEM" : null,
            "ARP" : null,
            "INTERFACESCALAR" : null,
            "INTERFACE" : null,
            "TCP_CONNECTION" : null
         },
      "operations" :
         {
            "CHANGEIFVLAN" : null,
            "CHANGEIFSTATUS" : null,
            "MIBSET" : null
         }
    }
    MO_STR
    @new_mo_str = <<-MO_STR
    {
      "endpoint" : {
            "Domain" : "a",
            "IP" : "104.104.104.60"
      },
      "accesses" : {
            "SNMPPARAMETER" :
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
  end
end