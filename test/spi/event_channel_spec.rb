# encoding: utf-8
# @author Kadvin, Date: 12-5-14
require File.join(File.dirname(__FILE__), "../env")
require File.join(File.dirname(__FILE__), "../../lib/spi")
require File.join(File.dirname(__FILE__), "http_mock_ext")

describe "Event Channel SPI" do
  before(:all) do
    Spi::Base.site = "http://20.0.8.167:8020/v1/"
    events = %Q{
      [{"occurredAt":"2012-05-16 16:14:32.515+0800", "catalog":"dsat.spi.event", "attributes":{"rule.eventType":"test", "trigger.description":"CPU", "trigger.label":"xx", "projection":"CPU", "engine.key":"00000000-1111-2222-3333-444444444444", "engine.name":"DefaultEngine", "moKey":"54366ab7-82b2-4ac1-bf0b-be87f10fd5cc", "currentValue":12, "rule.key":"6a9b0798-e907-4527-9957-e8429b3802f4"}, "uid":"8ac80874-5831-4f60-bf37-228dff3b17d8"},
       {"occurredAt":"2012-05-16 16:14:40.203+0800", "catalog":"dsat.spi.event", "attributes":{"rule.eventType":"test", "trigger.description":"CPU", "trigger.label":"x", "projection":"CPU", "engine.key":"00000000-1111-2222-3333-444444444444", "engine.name":"DefaultEngine", "moKey":"54366ab7-82b2-4ac1-bf0b-be87f10fd5cc", "currentValue":12, "rule.key":"6a9b0798-e907-4527-9957-e8429b3802f4"}, "uid":"7ec1bf16-e9ae-47c3-a670-721ab487a677"}]
    }
    events2 = %Q{[{"occurredAt":"2012-05-16 16:14:32.515+0800", "catalog":"dsat.spi.event", "attributes":{"rule.eventType":"test", "trigger.description":"CPU", "trigger.label":"xx", "projection":"CPU", "engine.key":"00000000-1111-2222-3333-444444444444", "engine.name":"DefaultEngine", "moKey":"54366ab7-82b2-4ac1-bf0b-be87f10fd5cc", "currentValue":12, "rule.key":"6a9b0798-e907-4527-9957-e8429b3802f4"}, "uid":"8ac80874-5831-4f60-bf37-228dff3b17d8"}]}
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/v1/events/channels.json", {}, %Q[{"channel-a" : 10, "channel-b" : 5}], 200, {}
      mock.get "/v1/events/channel-b.json?anchor=&limit=2", {}, events, 200, {"anchor" => "event@123"}
      mock.get "/v1/events/channel-b.json?anchor=event%40123&limit=2", {}, events2, 200, {"anchor" => "last@234"}
      mock.get "/v1/events/channel-b.json?anchor=last%40234&limit=2", {}, "[]", 200, {}
    end
  end

  it "can find all channels" do
    channels = Spi::EventChannel.all
    channels.each do |ch|
      p ch
    end
    channels.should have(2).items
  end

  it "can list events in the channel" do
    channels = Spi::EventChannel.all
    channel = channels.last
    events = channel.list(:limit => 2)
    channel.anchor.should == "event@123"
    events.each do |event|
      p event
    end
    events.should have(2).items
  end

  it "can iterate the events in the channel" do
    channels = Spi::EventChannel.all
    channel = channels.last
    channel.limit = 2
    p channel.name
    events = []
    channel.each do |event|
      p event
      events << event
    end
    channel.anchor.should be_nil
    events.should have(3).items
  end

end