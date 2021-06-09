require "./spec_helper"
require "webmock"
WebMock.stub(:any, "example.com")

describe Mechanize do
  it "simple get" do
    agent = Mechanize.new
    uri = "http://example.com/"
    page = agent.get(uri)
    page.code.should eq 200
    page.uri.to_s.should eq uri
  end
end
