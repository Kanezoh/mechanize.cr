require "./spec_helper"
require "webmock"
WebMock.stub(:get, "example.com")
WebMock.stub(:get, "fail_example.com").to_return(status: 500)
WebMock.stub(:get, "body_example.com").to_return(body: "hello")

describe "Mechanize Page test" do
  it "return status code of request" do
    agent = Mechanize.new
    page = agent.get("http://example.com/")
    page.code.should eq 200
    page = agent.get("http://fail_example.com")
    page.code.should eq 500
  end

  it "return request body" do
    agent = Mechanize.new
    page = agent.get("http://example.com/")
    page.body.should eq ""
    page = agent.get("http://body_example.com")
    page.body.should eq "hello"
  end
end
