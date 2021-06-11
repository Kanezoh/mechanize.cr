require "./spec_helper"
WebMock.stub(:get, "example.com")
WebMock.stub(:get, "http://example.com/?foo=bar&foo1=bar2")
WebMock.stub(:post, "http://example.com/post").
         with(body: "email=foobar", headers: {"Content-Type" => "application/x-www-form-urlencoded"}).
         to_return(body: "success")

describe "Mechanize HTTP test" do
  it "simple GET" do
    agent = Mechanize.new
    uri = "http://example.com/"
    page = agent.get(uri)
    page.code.should eq 200
    page.uri.to_s.should eq uri
  end

  it "GET with query parameter" do
    agent = Mechanize.new
    params = {"foo" => "bar", "foo1" => "bar2"}
    uri = "http://example.com/"
    page = agent.get(uri, params: params)
    page.code.should eq 200
    page.uri.to_s.should eq "http://example.com/?foo=bar&foo1=bar2"
  end

  it "GET with query parameter as URL string" do
    agent = Mechanize.new
    uri = "http://example.com/?foo=bar&foo1=bar2"
    page = agent.get(uri)
    page.code.should eq 200
    page.uri.to_s.should eq uri
  end

  it "set custom request headers" do
    agent = Mechanize.new
    uri = "http://example.com/"
    headers = HTTP::Headers{"Foo" => "Bar"}
    agent.request_headers.empty?.should eq true
    page = agent.get(uri, headers: headers)
    agent.request_headers.empty?.should eq false
    agent.request_headers["Foo"].should eq "Bar"
  end

  it "simple POST" do
    agent = Mechanize.new
    query = { "email" => "foobar" }
    page = agent.post("http://example.com/post", query: query)
    page.body.should eq "success"
    page.code.should eq 200
  end
end
