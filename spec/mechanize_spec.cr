require "./spec_helper"
require "webmock"
WebMock.stub(:any, "example.com")

describe Mechanize do
  it "simple GET" do
    agent = Mechanize.new
    uri = "http://example.com/"
    page = agent.get(uri)
    page.code.should eq 200
    page.uri.to_s.should eq uri
  end

  it "GET with query parameter" do
    WebMock.stub(:get, "http://example.com/?foo=bar&foo1=bar2")
    agent = Mechanize.new
    params = {"foo" => "bar", "foo1" => "bar2"}
    uri = "http://example.com/"
    page = agent.get(uri, params: params)
    page.code.should eq 200
    page.uri.to_s.should eq "http://example.com/?foo=bar&foo1=bar2"
  end
end
