# encoding: utf-8
# @author Kadvin, Date: 12-5-14
require File.join(File.dirname(__FILE__), "../env")
require File.join(File.dirname(__FILE__), "../../lib/spi")
require File.join(File.dirname(__FILE__), "http_mock_ext")

describe "Record Channel SPI" do

  before(:all) do
    Spi::Base.site = "http://localhost:8020/v1/"
    file1 = %W{{"key":"f03e9f53-6417-41b8-b983-fe60b7c6eefe","time":1337149630656,"value":12}
      {"key":"f03e9f53-6417-41b8-b983-fe60b7c6eefe","time":1337149645656,"value":12}}.join("\r\n")
    file2 = %W{{"key":"f03e9f53-6417-41b8-b983-fe60b7c6eefe","time":1337149630656,"value":12}}
    file3 = %W{{"key":"f03e9f53-6417-41b8-b983-fe60b7c6eefe","time":1337149630656,"value":12}
      {"key":"f03e9f53-6417-41b8-b983-fe60b7c6eefe","time":1337149645656,"value":12}}.join("\r\n")
    file4 = %W{{"key":"f03e9f53-6417-41b8-b983-fe60b7c6eefe","time":1337149630656,"value":12}}
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/records/channels.json", {}, %Q[{"channel-a" : 10, "channel-b" : 5}], 200, {}
      mock.get "/v1/records/channel-b.json?anchor=&limit=2", {}, [file1, file2].join("\r\n\r\n"), 200, {"anchor" => "event@123"}
      mock.get "/v1/records/channel-b.json?anchor=event%40123&limit=2", {}, [file3, file4].join("\r\n\r\n"), 200, {"anchor" => "last@234"}
      mock.get "/v1/records/channel-b.json?anchor=last%40234&limit=2", {}, "", 200
    end
  end

  it "can find all channels" do
    channels = Spi::RecordChannel.all
    channels.each do |ch|
      p ch
    end
    channels.should have(2).items
  end

  it "can list files in the channel" do
    channels = Spi::RecordChannel.all
    channel = channels.last
    files = channel.list(:limit => 2)
    files.should have(2).items
    p channel.name
    lines = []
    files.each do |file|
      file.split("\r\n").each do |line|
        p line
        lines << line
      end
      p
    end
    lines.should have(3).items
    channel.anchor.should == "event@123"
  end

  it "can iterate the files in the channel" do
    channels = Spi::RecordChannel.all
    channel = channels.last
    channel.limit = 2
    p channel.name
    lines = []
    channel.each do |file|
      file.split("\r\n").each do |line|
        p line
        lines << line
      end
      p ""
    end
    lines.should have(6).items
    channel.anchor.should be_nil
  end
end