# @author Kadvin, Date: 11-12-26
# add parent folder into ruby lib path
base = File.dirname(__FILE__)
$: << File.join(base, "../")
$: << File.join(base, "../lib")

require "rubygems"
require "rspec"
require "yaml"
require "actor/template"


describe "Template Resolving" do

  it "should resolve simple configurations with pure urls" do
    t = Actor::TemplateFile.new(File.join(base, "../templates/delete_mo.json"))
    t.session(1).should include("/engines?session=1")
    t.request(1, 2, "mo-special-key").should include("/mos/mo-special-key?session=1")
  end

  it "should do resolve complex configurations with body" do
    t = Actor::TemplateFile.new(File.join(base, "../templates/create_mo.json"))
    t.session(1).should include("/engines?session=1")
    r = t.request(1,2, "120.0.2.20")
    r.should include("\\\"120.0.2.20\\\"")
    r.should include("session=1")
  end

  it "should generate request url by sequenced configuration" do
    t = Actor::TemplateFile.new(File.join(base, "../templates/sample_mo.json"))
    t.session(1, "target-mo-key").should include("/mos/target-mo-key?session=1")
    t.request(1, 1, "target-mo-key").should include("/mos/target-mo-key/properties/UserName?burst=1")
    t.request(2, 2, "target-mo-key").should include("/mos/target-mo-key/properties/DeviceName?burst=2")
  end

end