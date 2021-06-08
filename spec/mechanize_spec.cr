require "./spec_helper"
require "webmock"
WebMock.stub(:any, "example.com")

describe Mechanize do
  # TODO: Write tests

  it "works" do
    response = HTTP::Client.get("http://example.com")
    response.body.should eq ""
    response.status_code.should eq 200
  end
end
