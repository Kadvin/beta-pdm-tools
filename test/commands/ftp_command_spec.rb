# @author Kadvin, Date: 11-12-23
require File.join(File.dirname(__FILE__), "prepare")
require "actor/ftp_server"

describe "Ftp Command" do

  %w[get put].each do |sub_cmd|
    it "should use ftp server to #{sub_cmd} files" do
      mock_ftp = Actor::FtpServer.new(:to => ".", :port => "21")

      Actor::FtpServer.stub(:new).and_return(mock_ftp)

      mock_ftp.should_receive(sub_cmd).with(*%w[. local/file1 local/file2])

      run("ftp #{sub_cmd} local/file1 local/file2")
    end

  end

end