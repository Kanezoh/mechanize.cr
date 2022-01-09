require "./spec_helper"
require "./server.cr"

describe "Mechanize HTTP Authentication test" do
  WebMock.allow_net_connect = true
  it "should be unsuccessful without credentials " do
    agent = Mechanize.new
    page = agent.get("#{TEST_SERVER_URL}/secret")
    page.code.should eq 401
    # WebMock.allow_net_connect = false
  end

  it "should be successful with credentials " do
    agent = Mechanize.new
    agent.add_auth("#{TEST_SERVER_URL}", "username", "password")
    page = agent.get("#{TEST_SERVER_URL}/secret")
    page.code.should eq 200
  end
end
